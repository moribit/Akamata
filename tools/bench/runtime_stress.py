#!/usr/bin/env python3
"""Bounded stress/fault evaluation. Owns only its fixture processes/sockets.

Expected Reactor worker starvation is recorded, not hidden by weakening Contract.
Long runs stay outside normal CI; --quick uses 32 idle clients and smaller waves.
"""
import argparse
import concurrent.futures
import contextlib
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import platform
import resource
import signal
import socket
import struct
import subprocess
import sys
import tempfile
import time

sys.dont_write_bytecode = True
p = argparse.ArgumentParser()
p.add_argument("binary")
p.add_argument("--output", required=True)
p.add_argument("--quick", action="store_true")
a = p.parse_args()
spec = importlib.util.spec_from_file_location("contract", Path(__file__).parents[2] / "tests/transport_contract.py")
contract = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contract)
soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
resource.setrlimit(resource.RLIMIT_NOFILE, (max(soft, min(2048, hard)), hard))
result = {"platform": platform.platform(), "binary_sha256": hashlib.sha256(Path(a.binary).read_bytes()).hexdigest(), "quick": a.quick, "runs": []}
Path(a.output).parent.mkdir(parents=True, exist_ok=True)
UPGRADE = b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"

def sample(pid):
    rss, cpu = subprocess.check_output(["ps", "-o", "rss=,time=", "-p", str(pid)], text=True).split()
    parts = cpu.split(":")
    seconds = sum(float(x) * 60 ** i for i, x in enumerate(reversed(parts)))
    if platform.system() == "Linux":
        threads = len(list(Path(f"/proc/{pid}/task").iterdir()))
        fds = len(list(Path(f"/proc/{pid}/fd").iterdir()))
    else:
        threads = len(subprocess.check_output(["ps", "-M", "-p", str(pid)], text=True).splitlines()) - 1
        fds = sum(row.startswith("f") and row[1:].isdigit() for row in subprocess.check_output(["lsof", "-a", "-p", str(pid), "-Ff"], text=True).splitlines())
    return {"rss_kib": int(rss), "cpu_seconds": seconds, "threads": threads, "fds": fds}

@contextlib.contextmanager
def server(adapter, name, fd_limit=None):
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0)); port = probe.getsockname()[1]
    run = {"adapter": adapter, "scenario": name}
    clients = []
    with tempfile.TemporaryFile() as log:
        proc = subprocess.Popen([str(Path(a.binary).resolve()), adapter, str(port), "stress"], stdout=log, stderr=log,
                                preexec_fn=(lambda: resource.setrlimit(resource.RLIMIT_NOFILE, (fd_limit, fd_limit))) if fd_limit else None)
        def connect():
            c = contract.Client(port); clients.append(c); return c
        try:
            for _ in range(100):
                if proc.poll() is not None: raise AssertionError("startup failed")
                try:
                    c = connect(); c.send(contract.request(close=True)); assert c.response()[0] == 200; c.close(); break
                except ConnectionRefusedError: time.sleep(.02)
            else: raise AssertionError("startup deadline")
            time.sleep(.05)
            run["before"] = sample(proc.pid)
            yield proc, connect, run
        finally:
            if proc.poll() is None:
                started = time.monotonic(); proc.send_signal(signal.SIGTERM)
                try: proc.wait(timeout=8)
                except subprocess.TimeoutExpired:
                    proc.kill(); proc.wait(); raise AssertionError("shutdown exceeded 8s")
                run.setdefault("shutdown_ms", (time.monotonic() - started) * 1000)
            for c in clients: c.close()
            log.seek(0); text = log.read().decode(errors="replace")
            assert proc.returncode == 0, text
            assert "memory address" not in text, text
            if fd_limit:
                run["accept_exhaustion_observed"] = "MFILE" in text or "errno 24" in text
                assert run["accept_exhaustion_observed"], text
            for line in text.splitlines():
                if line.startswith("BENCH_STATS "): run["allocator"] = json.loads(line.split(" ", 1)[1])
            assert run.get("allocator", {}).get("live") == 0, run
            run["success"] = True
            result["runs"].append(run)
            Path(a.output).write_text(json.dumps(result, indent=2) + "\n")
            print(adapter, name, "ok", flush=True)

def hello(connect):
    c = connect(); c.send(contract.request(close=True)); assert c.response()[2] == b"hello"; c.close()

adapters = ["threaded", "epoll" if platform.system() == "Linux" else "kqueue"]
for adapter in adapters:
    for count in ([32] if a.quick else [64, 256]):
        with server(adapter, f"idle-{count}") as (proc, connect, run):
            clients = [connect() for _ in range(count)]
            for c in clients: c.send(contract.request()); assert c.response()[0] == 200
            first = sample(proc.pid); started = time.monotonic(); time.sleep(.5); last = sample(proc.pid)
            run["loaded"] = last; run["idle_cpu_percent"] = 100 * (last["cpu_seconds"] - first["cpu_seconds"]) / (time.monotonic() - started)
            hello(connect)
            started = time.monotonic(); proc.send_signal(signal.SIGTERM); proc.wait(timeout=3)
            run["shutdown_ms"] = (time.monotonic() - started) * 1000
    with server(adapter, "burst-churn-pipeline-reset") as (proc, connect, run):
        waves = 4 if a.quick else 16
        concurrency = 16 if a.quick else 64
        def wave(_):
            c = connect(); c.send(contract.request() * 3)
            for _ in range(3): assert c.response()[2] == b"hello"
            c.sock.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0)); c.close()
        started = time.monotonic()
        with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
            list(pool.map(wave, range(waves * concurrency)))
        run["connections"] = waves * concurrency; run["elapsed_ms"] = (time.monotonic() - started) * 1000
        time.sleep(.2); run["after"] = sample(proc.pid)
        assert run["after"]["fds"] <= run["before"]["fds"] + 1, run
        hello(connect)
    with server(adapter, "partial-read-large-body-stream-upgrade-errors") as (proc, connect, run):
        slow = [connect() for _ in range(8 if a.quick else 32)]
        for c in slow: c.send(b"GET /hello HTTP/1.1\r\nHost:")
        time.sleep(.35)
        for c in slow: c.eof(); c.close()
        body = b"x" * (512 * 1024)
        c = connect(); head = b"POST /echo HTTP/1.1\r\nHost: a\r\nConnection: close\r\nContent-Length: " + str(len(body)).encode() + b"\r\n\r\n"
        for byte in head: c.send(bytes([byte]))
        for i in range(0, len(body), 3071): c.send(body[i:i + 3071])
        assert c.response()[2] == body; c.close()
        for path in ["/stream", "/stream-error", "/fixed", "/fixed-short", "/upgrade"]:
            c = connect(); c.send(contract.request(path, close=True, extra=UPGRADE if path == "/upgrade" else b"")); raw = c.collect(); c.close()
            assert raw.count(b"HTTP/1.1") == 1
        time.sleep(.1); run["after"] = sample(proc.pid)
        assert run["after"]["fds"] <= run["before"]["fds"] + 1, run
    with server(adapter, "slow-reader-load-forced-drain") as (proc, connect, run):
        readers = [connect() for _ in range(4)]
        for c in readers:
            c.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096); c.send(contract.request("/large"))
        time.sleep(.1); run["loaded"] = sample(proc.pid)
        started = time.monotonic(); proc.send_signal(signal.SIGTERM); proc.send_signal(signal.SIGTERM); proc.wait(timeout=3)
        run["shutdown_ms"] = (time.monotonic() - started) * 1000
        assert run["shutdown_ms"] < 1500
    for path in ("/stream", "/upgrade"):
        with server(adapter, path[1:] + "-latency-4") as (proc, connect, run):
            def exchange(_):
                started = time.monotonic()
                c = connect(); c.send(contract.request(path, close=True, extra=UPGRADE if path == "/upgrade" else b""))
                raw = c.collect(); c.close()
                assert raw.count(b"HTTP/1.1") == 1
                assert (b"upgraded" if path == "/upgrade" else b"one") in raw
                return (time.monotonic() - started) * 1000
            started = time.monotonic()
            count = 40 if a.quick else 200
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
                latencies = sorted(pool.map(exchange, range(count)))
            elapsed = time.monotonic() - started
            run["requests"] = count; run["throughput"] = count / elapsed
            run["latency_ms"] = {str(q): latencies[min(count - 1, int(count * q / 100))] for q in (50, 95, 99)}
            run["loaded"] = sample(proc.pid)
            run["cpu_percent"] = 100 * (run["loaded"]["cpu_seconds"] - run["before"]["cpu_seconds"]) / elapsed
    with server(adapter, "upgrade-worker-isolation-gate") as (proc, connect, run):
        upgrades = [connect() for _ in range(4)]
        for c in upgrades: c.send(contract.request("/upgrade-wait", extra=UPGRADE)); assert c.response()[0] == 101
        probe = connect(); probe.sock.settimeout(.25); started = time.monotonic(); probe.send(contract.request(close=True))
        try: run["unrelated_request_isolated"] = probe.response()[0] == 200
        except TimeoutError: run["unrelated_request_isolated"] = False
        run["probe_ms"] = (time.monotonic() - started) * 1000; run["loaded"] = sample(proc.pid)
        # Record the known architecture gap; public production remains disabled.
        assert run["unrelated_request_isolated"] == (adapter == "threaded"), run
        started = time.monotonic(); proc.send_signal(signal.SIGTERM); proc.wait(timeout=3)
        run["shutdown_ms"] = (time.monotonic() - started) * 1000
    with server(adapter, "accept-fd-exhaustion-recovery", fd_limit=64) as (proc, connect, run):
        held = []
        for _ in range(80):
            c = connect(); held.append(c); c.sock.settimeout(.3)
            c.send(contract.request())
            try: assert c.response()[0] == 200
            except (TimeoutError, ConnectionResetError, AssertionError): break
        first = sample(proc.pid); started = time.monotonic(); time.sleep(.3); last = sample(proc.pid)
        run["admitted"] = len(held) - 1
        run["exhausted_cpu_percent"] = 100 * (last["cpu_seconds"] - first["cpu_seconds"]) / (time.monotonic() - started)
        for c in held: c.close()
        time.sleep(.5); hello(connect)
        time.sleep(.1); run["after"] = sample(proc.pid)
        assert run["after"]["fds"] <= run["before"]["fds"] + 1, run
print("stress/fault evaluation complete; production gate remains disabled")
