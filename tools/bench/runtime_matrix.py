#!/usr/bin/env python3
"""Paired lifecycle matrix. Each case starts fresh servers, never kills others.

python3 tools/bench/runtime_matrix.py LABEL=BIN LABEL=BIN --output FILE
Allocation counts cover app.gpa, not SQLite/libc/stacks. CPU is process CPU time
delta divided by measurement wall time. Instrumentation is opt-in --stats.
"""
import argparse
import contextlib
import hashlib
import json
import os
import platform
import resource
import signal
import socket
import statistics
import subprocess
import tempfile
import time
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("binaries", nargs="+")
p.add_argument("--output", required=True)
p.add_argument("--connections", type=int, nargs="+", default=[4, 32, 128])
p.add_argument("--idle", type=int, nargs="+", default=[64, 256])
p.add_argument("--rounds", type=int, default=2)
p.add_argument("--duration", default="2s")
p.add_argument("--stats", action="store_true")
p.add_argument("--short-qps", type=int, default=500)
p.add_argument("--endpoints", nargs="+", default=["hello", "echo", "db/1"])
p.add_argument("--modes", nargs="+", choices=["keep_alive", "short_lived"], default=["keep_alive", "short_lived"])
p.add_argument("--skip-idle", action="store_true")
a = p.parse_args()
bins = [s.split("=", 1) for s in a.binaries]
soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
resource.setrlimit(resource.RLIMIT_NOFILE, (max(soft, min(2048, hard)), hard))
result = {"platform": platform.platform(), "stats_enabled": a.stats,
          "binaries": {n: {"path": path, "sha256": hashlib.sha256(Path(path).read_bytes()).hexdigest()} for n, path in bins},
          "oha_version": subprocess.check_output(["oha", "--version"], text=True).strip(), "runs": []}

def cpu_seconds(value):
    parts = value.split(":")
    return sum(float(x) * 60 ** i for i, x in enumerate(reversed(parts)))

def sample(pid):
    values = subprocess.check_output(["ps", "-o", "rss=,time=", "-p", str(pid)], text=True).split()
    if platform.system() == "Linux":
        threads = len(list(Path(f"/proc/{pid}/task").iterdir()))
    else:
        threads = max(0, len(subprocess.check_output(["ps", "-M", "-p", str(pid)], text=True).splitlines()) - 1)
    return {"rss_kib": int(values[0]), "cpu_seconds": cpu_seconds(values[1]), "threads": threads}

def fds(pid):
    if platform.system() == "Linux":
        return len(list(Path(f"/proc/{pid}/fd").iterdir()))
    rows = subprocess.check_output(["lsof", "-a", "-p", str(pid), "-Ff"], text=True).splitlines()
    return sum(row.startswith("f") and row[1:].isdigit() for row in rows)

@contextlib.contextmanager
def server(binary, run):
    with socket.socket() as probe:
        probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        probe.bind(("127.0.0.1", 8080))
        probe.listen(1)
    env = dict(os.environ)
    for key in ("BENCH_STATS", "BENCH_RUNTIME", "BENCH_OBSERVABILITY"):
        env.pop(key, None)
    if a.stats:
        env["BENCH_STATS"] = "1"
    with tempfile.TemporaryFile() as log:
        proc = subprocess.Popen([str(Path(binary).resolve())], env=env, stdout=subprocess.DEVNULL, stderr=log)
        try:
            for _ in range(100):
                if proc.poll() is not None:
                    raise RuntimeError("server exited at startup")
                try:
                    with socket.create_connection(("127.0.0.1", 8080), .2) as client:
                        client.sendall(b"GET /hello HTTP/1.1\r\nHost: a\r\nConnection: close\r\n\r\n")
                        if b"200" not in client.recv(4096):
                            raise RuntimeError("startup response")
                    break
                except OSError:
                    time.sleep(.02)
            else:
                raise RuntimeError("startup deadline")
            yield proc
        finally:
            if proc.poll() is None:
                proc.send_signal(signal.SIGTERM)
            started = time.monotonic()
            try:
                proc.wait(timeout=15)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
                raise RuntimeError("shutdown deadline exceeded")
            run["shutdown_ms"] = (time.monotonic() - started) * 1000
            log.seek(0)
            for row in log.read().decode(errors="replace").splitlines():
                if row.startswith("BENCH_STATS "):
                    run["allocator"] = json.loads(row.split(" ", 1)[1])
                elif row.startswith("BENCH_TASKS "):
                    run["tasks"] = json.loads(row.split(" ", 1)[1])
            if proc.returncode:
                raise RuntimeError(f"server exited {proc.returncode}")

def save(run):
    result["runs"].append(run)
    Path(a.output).write_text(json.dumps(result, indent=2) + "\n")
    raw = run.get("oha")
    print(run["label"], run["kind"], run["connections"], run.get("endpoint"),
          round(raw["statusCodeDistribution"].get("200", 0) / raw["summary"]["total"]) if raw else "idle",
          "threads", run["threads_peak"], flush=True)

for round_no in range(a.rounds):
    for connections in a.connections:
        for kind in a.modes:
            for endpoint, extra in [("hello", []), ("echo", ["-m", "POST", "-T", "application/json", "-d", '{"name":"x","n":42}']), ("db/1", [])]:
                if endpoint not in a.endpoints:
                    continue
                # Alternate order to reduce time/temperature bias.
                for label, binary in (bins if round_no % 2 == 0 else list(reversed(bins))):
                    run = {"label": label, "round": round_no + 1, "kind": kind, "connections": connections, "endpoint": endpoint}
                    with server(binary, run) as proc:
                        command = ["oha", "--no-tui", "--output-format", "json", "-c", str(connections), "-z", a.duration, "-w", *extra]
                        if kind == "short_lived":
                            # Keep the host's TIME_WAIT/source-port usage safe.
                            # This measures latency/resources at a fixed rate,
                            # not the short-lived throughput ceiling.
                            command += ["-H", "Connection: close", "-q", str(a.short_qps)]
                        command += ["http://127.0.0.1:8080/" + endpoint]
                        run["command"] = command
                        before = sample(proc.pid)
                        started = time.monotonic()
                        client = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        samples = []
                        while client.poll() is None:
                            samples.append(sample(proc.pid))
                            time.sleep(.25)
                        stdout, stderr = client.communicate()
                        if client.returncode:
                            raise RuntimeError(stderr.decode())
                        run["oha"] = json.loads(stdout)
                        after = sample(proc.pid)
                        run["cpu_percent"] = 100 * (after["cpu_seconds"] - before["cpu_seconds"]) / (time.monotonic() - started)
                        run["rss_mean_kib"] = statistics.mean(s["rss_kib"] for s in samples)
                        run["threads_peak"] = max(s["threads"] for s in samples)
                        run["fd_count"] = fds(proc.pid)
                    save(run)

for connections in ([] if a.skip_idle else a.idle):
    for label, binary in bins:
        run = {"label": label, "kind": "idle", "connections": connections}
        with server(binary, run) as proc:
            clients = []
            try:
                for _ in range(connections):
                    client = socket.create_connection(("127.0.0.1", 8080), 2)
                    clients.append(client)
                    client.sendall(b"GET /hello HTTP/1.1\r\nHost: a\r\n\r\n")
                    if b"200" not in client.recv(4096):
                        raise RuntimeError("idle admission failed")
                before = sample(proc.pid)
                started = time.monotonic()
                time.sleep(1)
                after = sample(proc.pid)
                run.update(cpu_percent=100 * (after["cpu_seconds"] - before["cpu_seconds"]) / (time.monotonic() - started),
                           rss_mean_kib=after["rss_kib"], threads_peak=after["threads"], fd_count=fds(proc.pid))
                # Leave idle clients connected during shutdown.
                proc.send_signal(signal.SIGTERM)
                proc.wait(timeout=3)
            finally:
                for client in clients:
                    client.close()
        save(run)
