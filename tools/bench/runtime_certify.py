#!/usr/bin/env python3
"""Owned-process, bounded Native session scalability/mixed/soak certification.

Timing under this Python driver measures isolation, not peak request throughput.
Both adapters use identical incremental application callbacks. No production gate
is changed by this runner. Results are checkpointed even on failure.
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
import selectors
import signal
import socket
import statistics
import struct
import subprocess
import sys
import tempfile
import time
import threading

sys.dont_write_bytecode = True
p = argparse.ArgumentParser()
p.add_argument("binary")
p.add_argument("--output", required=True)
p.add_argument("--idle-levels", nargs="+", type=int, default=[100, 1000])
p.add_argument("--soak-seconds", type=int, default=1200)
p.add_argument("--mixed-idle", type=int, default=100)
p.add_argument("--adapters", nargs="+")
p.add_argument("--session-rounds", type=int, default=50)
a = p.parse_args()
assert 0 <= a.soak_seconds <= 14400
assert 0 <= a.mixed_idle <= 5000
assert 1 <= a.session_rounds <= 1000
assert all(0 < n <= 10000 for n in a.idle_levels)
binary = Path(a.binary).resolve()
spec = importlib.util.spec_from_file_location("contract", Path(__file__).parents[2] / "tests/transport_contract.py")
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
ceiling = 16384 if hard == resource.RLIM_INFINITY else min(hard, 16384)
resource.setrlimit(resource.RLIMIT_NOFILE, (max(soft, ceiling), hard))
result = {"source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(), "working_tree_dirty": bool(subprocess.check_output(["git", "status", "--porcelain"], text=True).strip()), "close_reason_order": ["completed", "disconnected", "timeout", "shutdown", "application_error"], "platform": platform.platform(), "zig_version": subprocess.check_output(["zig", "version"], text=True).strip(), "binary_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(), "command": sys.argv, "thread_count_method": "proc-task" if platform.system() == "Linux" else "ps-M-minus-header", "rlimit_nofile": resource.getrlimit(resource.RLIMIT_NOFILE), "runs": [], "limitations": ["Python load generator is not a peak throughput benchmark", "allocator counters exclude libc/SQLite and thread stacks", "application callbacks remain cooperatively bounded"]}

def save():
    out = Path(a.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + "\n")

def resources(pid):
    line = subprocess.check_output(["ps", "-p", str(pid), "-o", "rss=,pcpu="], text=True).split()
    if platform.system() == "Linux":
        fds = len(list(Path(f"/proc/{pid}/fd").iterdir()))
        threads = len(list(Path(f"/proc/{pid}/task").iterdir()))
    else:
        listing = subprocess.run(["lsof", "-nP", "-p", str(pid), "-F", "f"], text=True, capture_output=True)
        fds = sum(x.startswith("f") and x[1:].isdigit() for x in listing.stdout.splitlines())
        # Darwin -M still emits its thread-table header despite -o pid=.
        threads = max(0, len(subprocess.check_output(["ps", "-M", "-p", str(pid)], text=True).splitlines()) - 1)
    return {"rss_kib": int(line[0]), "cpu_percent": float(line[1]), "fds": fds, "threads": threads}

@contextlib.contextmanager
def server(adapter, scenario):
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0))
        port = probe.getsockname()[1]
    run = {"adapter": adapter, "scenario": scenario, "samples": []}
    result["runs"].append(run)
    with tempfile.TemporaryFile() as log:
        proc = subprocess.Popen([str(binary), adapter, str(port), "incremental-certify"], stdout=log, stderr=log)
        def wait_work_started():
            for _ in range(100):
                if b"APPLICATION_WORK_ENTERED" in os.pread(log.fileno(), 65536, 0):
                    return
                time.sleep(.01)
            raise AssertionError("finite application work start barrier")
        proc.wait_work_started = wait_work_started
        try:
            for _ in range(100):
                try:
                    query(port, "/hello")
                    break
                except ConnectionRefusedError:
                    assert proc.poll() is None, "fixture startup failed"
                    time.sleep(.02)
            else:
                raise AssertionError("startup deadline")
            run["baseline"] = resources(proc.pid)
            yield port, proc, run
        except Exception as exc:
            run["error"] = repr(exc)
            try:
                run["failure_snapshot"] = sample(port, proc, 0)
            except Exception as snapshot_error:
                run["failure_snapshot_error"] = repr(snapshot_error)
            raise
        finally:
            start = time.monotonic()
            if proc.poll() is None:
                # A prior signal may already have returned from serve() and
                # restored the application's original disposition. Never send
                # a third cleanup signal into that post-runtime teardown.
                if not run.get("shutdown_requested"):
                    proc.send_signal(signal.SIGTERM)
                try:
                    proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
                    run["shutdown_deadline_failed"] = True
            run["shutdown_ms"] = (time.monotonic() - start) * 1000
            log.seek(0)
            text = log.read().decode(errors="replace")
            run["exit_code"] = proc.returncode
            for marker, key in (("BENCH_STATS ", "allocator_final"), ("SESSION_STATS ", "sessions_final"), ("RUNTIME_MEMORY ", "runtime_memory"), ("APPLICATION_MEMORY ", "application_memory")):
                lines = [line.split(marker, 1)[1] for line in text.splitlines() if marker in line]
                if lines:
                    run[key] = json.loads(lines[-1])
            run["clean"] = proc.returncode == 0 and run.get("allocator_final", {}).get("live") == 0 and run.get("sessions_final", {}).get("created") == run.get("sessions_final", {}).get("closed") and "sessions_final" in run
            if not run["clean"]:
                run["stderr_tail"] = text[-12000:]
            save()
            assert run["clean"], run

def query(port, path):
    client = c.Client(port)
    try:
        start = time.monotonic()
        client.send(c.request(path, close=True))
        status, _, body = client.response()
        assert status == 200, (path, status)
        return (time.monotonic() - start) * 1000, body
    finally:
        client.close()

def websocket(port):
    client = c.Client(port)
    try:
        client.send(c.request("/upgrade-live", extra=c.UPGRADE))
        assert client.response()[0] == 101
        c.receive_bytes(client, b"\x81\x05ready")
        return client
    except Exception:
        client.close()
        raise

def broadcast(clients, payload=b"tick"):
    start = time.monotonic()
    expected = b"\x81" + bytes([len(payload)]) + payload
    clients[0].send(c.masked_frame(1, payload))
    selector = selectors.DefaultSelector()
    try:
        for client in clients:
            selector.register(client.sock, selectors.EVENT_READ, client)
        deadline = start + 5
        while selector.get_map():
            for key in list(selector.get_map().values()):
                client = key.data
                if len(client.pending) >= len(expected):
                    assert client.pending[:len(expected)] == expected
                    client.pending = client.pending[len(expected):]
                    selector.unregister(client.sock)
            if not selector.get_map():
                break
            assert time.monotonic() < deadline, "broadcast deadline"
            for key, _ in selector.select(min(.1, max(0, deadline-time.monotonic()))):
                chunk = key.data.sock.recv(65536)
                assert chunk, "broadcast recipient disconnected"
                key.data.pending += chunk
        return (time.monotonic() - start) * 1000
    finally:
        selector.close()

def sample(port, proc, elapsed):
    _, body = query(port, "/runtime-stats")
    return {"elapsed_s": elapsed, **resources(proc.pid), "allocator": json.loads(body)}

def mixed(port, clients, pool):
    # Tasks run concurrently with broadcast and slow, bounded-output producers.
    slow = []
    try:
        for _ in range(4):
            client = c.Client(port)
            slow.append(client)
            client.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
            client.send(c.request("/large"))
            while b"\r\n\r\n" not in client.pending:
                chunk = client.sock.recv(1024)
                assert chunk
                client.pending += chunk
        probes = [pool.submit(query, port, "/db/1" if n % 3 == 0 else "/hello") for n in range(32)]
        latency = broadcast(clients)
        values = [future.result(timeout=5)[0] for future in probes]
        return {"http_p50_ms": statistics.median(values), "http_max_ms": max(values), "broadcast_ms": latency}
    finally:
        for client in slow:
            client.close()

def percentiles(values):
    values = sorted(values)
    return {"p50_ms": statistics.median(values), "p95_ms": values[min(len(values)-1, int(len(values)*.95))], "p99_ms": values[min(len(values)-1, int(len(values)*.99))]}

def small_stream(port):
    client = c.Client(port)
    try:
        start = time.monotonic()
        client.send(c.request("/stream", close=True))
        wire = client.collect()
        assert wire.startswith(b"HTTP/1.1 200")
        assert wire.split(b"\r\n\r\n", 1)[1] == b"3\r\none\r\n3\r\ntwo\r\n0\r\n\r\n"
        return (time.monotonic()-start)*1000
    finally:
        client.close()

def race_session(port, index):
    if index % 4 == 0:
        client = c.Client(port)
        client.send(c.request("/db/1", close=True))
    else:
        client = websocket(port)
        if index % 4 == 1:
            client.send(c.masked_frame(1, b"race")[:7])  # partial payload
        elif index % 4 == 2:
            client.send(c.masked_frame(9, b"race"))
        else:
            client.send(c.masked_frame(8, b"\x03\xe8"))
    try:
        if index % 2 == 0:
            client.sock.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0))
    finally:
        client.close()

try:
    for adapter in a.adapters or ["threaded", "epoll" if platform.system() == "Linux" else "kqueue"]:
        clients = []
        try:
            with server(adapter, "session-performance") as (port, proc, run), concurrent.futures.ThreadPoolExecutor(max_workers=32) as pool:
                for _ in range(100):
                    clients.append(websocket(port))
                broadcast_times = [broadcast(clients) for _ in range(a.session_rounds)]
                run["broadcast"] = {**percentiles(broadcast_times), "recipients": 100, "rounds": a.session_rounds, "observed_frames_per_second": 100*a.session_rounds/(sum(broadcast_times)/1000)}
                start = time.monotonic()
                futures = [pool.submit(small_stream, port) for _ in range(a.session_rounds*32)]
                stream_times = [future.result(timeout=5) for future in futures]
                run["stream"] = {**percentiles(stream_times), "requests": len(stream_times), "observed_requests_per_second": len(stream_times)/(time.monotonic()-start)}
                run["samples"].append(sample(port, proc, 0))
        except Exception as exc:
            result["limitations"].append(f"{adapter} session performance: {exc!r}")
        finally:
            for client in clients:
                client.close()
        with server(adapter, "disconnect-fd-reuse-races") as (port, proc, run), concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
            for future in [pool.submit(race_session, port, n) for n in range(256)]:
                future.result(timeout=5)
            deadline = time.monotonic()+3
            while True:
                snapshot = sample(port, proc, 0)
                stats = snapshot["allocator"]
                if stats["created"] == stats["closed"]:
                    break
                assert time.monotonic() < deadline, "race session cleanup deadline"
                time.sleep(.01)
            run["samples"].append(snapshot)
            run["iterations"] = 256
            run["recovered_http_ms"] = query(port, "/hello")[0]
        clients = []
        try:
            with server(adapter, "shutdown-disconnect-completion-race") as (port, proc, run), concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
                for _ in range(64):
                    clients.append(websocket(port))
                start = threading.Event()
                def close_race(client):
                    start.wait(timeout=2)
                    try:
                        client.send(c.masked_frame(9, b"bye"))
                    except OSError:
                        pass  # Peer shutdown races with this owned client.
                    finally:
                        client.close()
                futures = [pool.submit(close_race, client) for client in clients]
                work = c.Client(port)
                clients.append(work)
                work.send(c.request("/application-hold"))
                proc.wait_work_started()
                start.set()
                run["shutdown_requested"] = True
                proc.send_signal(signal.SIGTERM)
                if proc.poll() is None:
                    try:
                        proc.send_signal(signal.SIGINT)
                    except ProcessLookupError:
                        pass
                for future in futures:
                    future.result(timeout=5)
                run["connections"] = 64
        finally:
            for client in clients:
                client.close()
        for count in a.idle_levels:
            if count + 128 > ceiling:
                result["runs"].append({"adapter": adapter, "scenario": "idle", "count": count, "skipped": "safe fd ceiling"})
                continue
            clients = []
            try:
                with server(adapter, "idle") as (port, proc, run):
                    run["count"] = count
                    begin = time.monotonic()
                    for _ in range(count):
                        clients.append(websocket(port))
                    run["establishment_ms"] = (time.monotonic() - begin) * 1000
                    run["samples"].append(sample(port, proc, 0))
                    run["broadcast_ms"] = broadcast(clients)
                    run["http_probe_ms"] = query(port, "/hello")[0]
                    assert run["http_probe_ms"] < 250, run
                    # Leave sessions connected until bounded server drain.
            except Exception as exc:
                result["limitations"].append(f"{adapter} idle {count}: {exc!r}")
                save()
            finally:
                for client in clients:
                    client.close()
        clients = []
        try:
            with server(adapter, "mixed-soak-races") as (port, proc, run), concurrent.futures.ThreadPoolExecutor(max_workers=32) as pool:
                for _ in range(a.mixed_idle + 16):
                    clients.append(websocket(port))
                start = time.monotonic()
                duration = max(1, a.soak_seconds)
                run["requested_soak_s"] = a.soak_seconds
                run["mixed_results"] = []
                iterations = 0
                while time.monotonic() - start < duration:
                    # Read deadlines are intentionally not disabled for soak.
                    # Heartbeats renew each complete-frame budget, including
                    # otherwise idle broadcast recipients.
                    for client in clients:
                        client.send(c.masked_frame(9, b"live"))
                    for client in clients:
                        c.receive_bytes(client, b"\x8a\x04live")
                    clients.append(clients.pop(0))
                    run["mixed_results"].append(mixed(port, clients, pool))
                    # Reconnect/close races while workers complete broadcasts.
                    for _ in range(4):
                        client = websocket(port)
                        client.send(c.masked_frame(8, b"\x03\xe8"))
                        client.close()
                    if iterations % 3 == 0:
                        run["samples"].append(sample(port, proc, time.monotonic() - start))
                        save()
                    iterations += 1
                    time.sleep(min(2, max(0, duration-(time.monotonic()-start))))
                run["elapsed_s"] = time.monotonic() - start
                run["iterations"] = iterations
                run["http_isolated"] = all(x["http_max_ms"] < 250 for x in run["mixed_results"])
                assert run["http_isolated"], "mixed HTTP isolation failed"
        except Exception as exc:
            result["limitations"].append(f"{adapter} mixed/soak: {exc!r}")
            save()
        finally:
            for client in clients:
                client.close()
    result["passed"] = all(r.get("clean", False) and "error" not in r for r in result["runs"] if "skipped" not in r)
    result["long_soak_completed"] = a.soak_seconds >= 1200 and all(r.get("elapsed_s", 0) >= a.soak_seconds for r in result["runs"] if r["scenario"] == "mixed-soak-races")
finally:
    save()

if not result.get("passed", False):
    raise SystemExit("certification evidence has unmet conditions; retain production gate")
