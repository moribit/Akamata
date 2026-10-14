#!/usr/bin/env python3
"""Serial, checkpointed comparison. Defaults are the requested certification matrix.

No builds, dependency downloads or concurrent suites belong in this process.
Different warmup/duration/round counts are explicitly exploratory, never relabeled.
Server command manifests include optional environment overrides for private runtimes.
"""
import argparse
import contextlib
import fcntl
import hashlib
import http.client
import json
import os
import platform
import random
import resource
import signal
import socket
import statistics
import subprocess
import tempfile
import time
from pathlib import Path

WORKLOADS = {
    "plaintext": ("GET", "/plaintext", None, "text/plain; charset=utf-8", b"Hello, World!"),
    "json": ("GET", "/json", None, "application/json", b'{"message":"Hello, World!"}'),
    "routing": ("GET", "/users/123/posts/456", None, "application/json", b'{"user":123,"post":456}'),
    "db": ("GET", "/db/1", None, "application/json", b'{"id":1,"name":"alpha","weight":1.5}'),
}
for size in (64, 1024, 65536):
    WORKLOADS[f"echo-{size}"] = ("POST", "/echo", b"x" * size, "application/octet-stream", b"x" * size)

def cpu_time(value):
    return sum(float(part) * 60 ** i for i, part in enumerate(reversed(value.split(":"))))

def runtime_reports(log):
    reports = {}
    for line in log.splitlines():
        for marker, field in (("RUNTIME_COST ", "runtime_cost"), ("BENCH_STATS ", "allocator"), ("RUNTIME_MEMORY ", "runtime_memory")):
            if line.startswith(marker):
                if field in reports:
                    raise ValueError(f"duplicate diagnostic report: {field}")
                reports[field] = json.loads(line[len(marker):])
    return reports

def sample(pid):
    data = subprocess.check_output(["ps", "-o", "rss=,time=", "-p", str(pid)], text=True).split()
    if platform.system() == "Linux":
        threads = len(list(Path(f"/proc/{pid}/task").iterdir()))
    else:
        threads = len(subprocess.check_output(["ps", "-M", "-p", str(pid)], text=True).splitlines()) - 1
    return {"rss_kib": int(data[0]), "cpu_seconds": cpu_time(data[1]), "threads": max(0, threads)}

def verify():
    conn = http.client.HTTPConnection("127.0.0.1", 8088, timeout=5)
    checks = []
    try:
        for name, (method, path, body, content_type, expected) in WORKLOADS.items():
            conn.request(method, path, body, {"Content-Type": "application/octet-stream"} if body else {})
            response = conn.getresponse()
            actual = response.read()
            checks.append({"workload":name,"status":response.status,"http_version":response.version,"headers":response.getheaders(),"body_bytes":len(actual),"body_sha256":hashlib.sha256(actual).hexdigest()})
            assert response.version == 11, (name, "not HTTP/1.1")
            assert response.status == 200, (name, response.status, actual[:100])
            assert response.getheader("Content-Type") == content_type, (name, response.getheader("Content-Type"), content_type)
            assert actual == expected, (name, actual[:100], expected[:100])
    finally:
        conn.close()
    return checks

@contextlib.contextmanager
def owned_load(command, out, err):
    process = subprocess.Popen(command, stdout=out, stderr=err)
    try:
        yield process
    finally:
        # Interrupts/sampling failures must not leave a generator applying load
        # after its server or the owning measurement process has been stopped.
        if process.poll() is None:
            process.kill()
        process.wait()


def load(command, server, seconds):
    with tempfile.TemporaryFile() as out, tempfile.TemporaryFile() as err:
        with owned_load(command, out, err) as process:
            return collect_load(process, server, seconds, out, err)


def collect_load(process, server, seconds, out, err):
    initial = sample(server.pid)
    started = time.monotonic()
    samples = []
    while process.poll() is None:
        if server.poll() is not None:
            process.kill(); process.wait()
            raise RuntimeError("server exited during load")
        if time.monotonic() - started > seconds + 60:
            process.kill(); process.wait()
            raise RuntimeError("load generator exceeded bounded drain")
        try:
            generator = sample(process.pid)
        except (subprocess.CalledProcessError, IndexError, FileNotFoundError):
            # The child may exit between poll() and ps. Preserve its exit
            # status below; an absent final sample is not a load failure.
            if process.poll() is None:
                raise
            generator = None
        samples.append({"server": sample(server.pid), "generator": generator})
        try:
            process.wait(timeout=1)
        except subprocess.TimeoutExpired:
            pass
    final = sample(server.pid)
    elapsed = time.monotonic() - started
    out.seek(0); err.seek(0)
    output, errors = out.read(), err.read().decode()
    if process.returncode:
        raise RuntimeError(f"oha exit {process.returncode}: {errors}")
    return {"oha": json.loads(output), "process_samples": samples,
            "cpu_percent": 100 * (final["cpu_seconds"] - initial["cpu_seconds"]) / elapsed,
            "rss_mean_kib": statistics.mean(s["server"]["rss_kib"] for s in samples),
            "threads_peak": max(s["server"]["threads"] for s in samples),
            "measurement_wall_seconds": elapsed, "stderr": errors}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest")
    parser.add_argument("--output", required=True)
    parser.add_argument("--frameworks", nargs="+")
    parser.add_argument("--workloads", nargs="+", default=list(WORKLOADS))
    parser.add_argument("--connections", type=int, nargs="+", default=[1, 8, 32, 128, 512, 1024])
    parser.add_argument("--warmup", type=int, default=10)
    parser.add_argument("--duration", type=int, default=30)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--seed", type=int, default=20261013)
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--shutdown-wait", type=int, default=45,
                        help="runner cleanup bound; must exceed Native's 30s default I/O drain")
    args = parser.parse_args()
    if min(args.connections) < 1 or max(args.connections) > 1024:
        parser.error("explicit OS safety review required above 1024")
    if args.shutdown_wait < 1:
        parser.error("shutdown wait must be positive")
    soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
    resource.setrlimit(resource.RLIMIT_NOFILE, (max(soft, min(4096, hard)), hard))
    manifest = json.loads(Path(args.manifest).read_text())
    frameworks = args.frameworks or list(manifest)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    # A checkpoint can be resumed, but never by two writers concurrently.
    # Keep the descriptor alive until main returns; process exit releases it.
    checkpoint_lock = output.with_suffix(output.suffix + ".lock").open("a+")
    try:
        fcntl.flock(checkpoint_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        parser.error(f"another measurement owns {output}")
    binaries = {name: {**manifest[name], "sha256": hashlib.sha256(Path(manifest[name]["command"][0]).read_bytes()).hexdigest()} for name in frameworks}
    for name in frameworks:
        binaries[name]["artifact_sha256"] = {path: hashlib.sha256(Path(path).read_bytes()).hexdigest() for path in manifest[name].get("artifacts", [])}
    certified = args.warmup == 10 and args.duration == 30 and args.rounds == 5
    result = {"schema": 1, "classification": "requested-duration" if certified else "exploratory",
              "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
              "command": __import__("sys").argv, "os": platform.platform(), "cpu_count": os.cpu_count(),
              "invocations": [__import__("sys").argv],
              "oha": subprocess.check_output(["oha", "--version"], text=True).strip(),
              "warmup_seconds": args.warmup, "duration_seconds": args.duration, "rounds": args.rounds,
              "binaries": binaries, "runs": []}
    result["shutdown_wait_seconds"] = args.shutdown_wait
    if args.resume and output.exists():
        previous = json.loads(output.read_text())
        # Fixture source identity belongs to each frozen binary. The harness
        # may acquire a documentation/profiling commit while a long run is
        # checkpointed; record that revision instead of conflating it with
        # the executable being measured. Changing a binary still fails closed.
        for key in ("binaries", "warmup_seconds", "duration_seconds", "rounds", "os", "cpu_count", "oha"):
            assert previous[key] == result[key], f"resume drift: {key}"
        revisions = previous.setdefault("harness_revisions", [previous["source_sha"]])
        if result["source_sha"] not in revisions:
            revisions.append(result["source_sha"])
        invocations = previous.setdefault("invocations", [previous["command"]])
        if result["command"] not in invocations:
            invocations.append(result["command"])
        result = previous
        if result.get("shutdown_wait_seconds", 10) != args.shutdown_wait:
            result.setdefault("shutdown_policy_revisions", []).append({
                "previous_seconds": result.get("shutdown_wait_seconds", 10),
                "seconds": args.shutdown_wait,
                "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
                "reason": "allow configured Native 30s drain; measurement conditions/binaries unchanged"})
        result["shutdown_wait_seconds"] = args.shutdown_wait
    done = {(r["framework"], r["workload"], r["connections"], r["round"]) for r in result["runs"] if "oha" in r}
    def save():
        temporary = output.with_suffix(".tmp")
        temporary.write_text(json.dumps(result, indent=2) + "\n")
        temporary.replace(output)
    save()
    for round_no in range(1, args.rounds + 1):
        for workload in args.workloads:
            method, path, body, _, _ = WORKLOADS[workload]
            for connections in args.connections:
                order = list(frameworks)
                random.Random(args.seed + round_no + connections + list(WORKLOADS).index(workload)).shuffle(order)
                for name in order:
                    if (name, workload, connections, round_no) in done:
                        continue
                    print(f"round={round_no} workload={workload} c={connections} framework={name}", flush=True)
                    row = {"framework": name, "workload": workload, "connections": connections, "round": round_no,
                           "runner_shutdown_wait_seconds": args.shutdown_wait}
                    with tempfile.TemporaryFile() as log, tempfile.TemporaryDirectory() as directory:
                        # Refuse occupied ports before starting, never kill another process.
                        with socket.socket() as probe:
                            probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                            probe.bind(("127.0.0.1", 8088))
                        process = subprocess.Popen(manifest[name]["command"], env={**os.environ, **manifest[name].get("env", {})}, stdout=log, stderr=log)
                        try:
                            deadline = time.monotonic() + 10
                            while True:
                                if process.poll() is not None:
                                    raise RuntimeError("server startup failed")
                                try:
                                    with socket.create_connection(("127.0.0.1", 8088), .2): pass
                                    break
                                except OSError:
                                    if time.monotonic() >= deadline: raise
                                    time.sleep(.02)
                            row["wire_checks"] = verify()
                            extra = []
                            if body is not None:
                                payload = Path(directory) / "body.bin"
                                payload.write_bytes(body)
                                extra = ["-m", method, "-T", "application/octet-stream", "-D", str(payload)]
                            def command(seconds):
                                return ["oha", "--no-tui", "--output-format", "json", "--http-version", "1.1", "-c", str(connections), "-z", f"{seconds}s", "-t", "10s", "-w", *extra, "http://127.0.0.1:8088" + path]
                            if args.warmup:
                                row["warmup"] = load(command(args.warmup), process, args.warmup)
                            row["load_command"] = command(args.duration)
                            row.update(load(row["load_command"], process, args.duration))
                        except Exception as error:
                            row["failure"] = str(error)
                            raise
                        finally:
                            started = time.monotonic()
                            if process.poll() is None: process.send_signal(signal.SIGINT)
                            try: process.wait(timeout=args.shutdown_wait)
                            except subprocess.TimeoutExpired:
                                process.kill(); process.wait(); row["forced_runner_cleanup"] = True
                            row["shutdown_ms"] = (time.monotonic() - started) * 1000
                            row["server_exit"] = process.returncode
                            log.seek(0); row["server_log"] = log.read().decode(errors="replace")
                            try:
                                row.update(runtime_reports(row["server_log"]))
                            except (ValueError, json.JSONDecodeError) as error:
                                row["diagnostic_parse_failure"] = str(error)
                            result["runs"].append(row); save()

if __name__ == "__main__":
    main()
