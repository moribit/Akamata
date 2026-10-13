#!/usr/bin/env python3
"""Bounded idle keep-alive diagnostics, separate from request throughput."""
import argparse
import hashlib
import http.client
import json
import os
import platform
import resource
import signal
import socket
import subprocess
import tempfile
import time
from pathlib import Path

from measure import sample, verify


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest")
    parser.add_argument("--output", required=True)
    parser.add_argument("--frameworks", nargs="+")
    parser.add_argument("--connections", type=int, nargs="+", default=[32, 128, 512, 1024])
    parser.add_argument("--seconds", type=int, default=20)
    parser.add_argument("--rounds", type=int, default=3)
    args = parser.parse_args()
    if min(args.connections) < 1 or max(args.connections) > 1024 or args.seconds < 1:
        parser.error("safe connection range is 1..1024; duration must be positive")
    soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
    resource.setrlimit(resource.RLIMIT_NOFILE, (max(soft, min(4096, hard)), hard))
    manifest = json.loads(Path(args.manifest).read_text())
    frameworks = args.frameworks or list(manifest)
    output = Path(args.output)
    if output.exists():
        parser.error("refusing to overwrite idle evidence")
    output.parent.mkdir(parents=True, exist_ok=True)
    result = {"classification": "idle-diagnostic", "command": __import__("sys").argv,
              "platform": platform.platform(), "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
              "fd_limit": resource.getrlimit(resource.RLIMIT_NOFILE),
              "binaries": {name: {**manifest[name], "sha256": hashlib.sha256(Path(manifest[name]["command"][0]).read_bytes()).hexdigest()} for name in frameworks}, "runs": []}
    def save():
        temporary = output.with_suffix(".tmp")
        temporary.write_text(json.dumps(result, indent=2) + "\n")
        temporary.replace(output)
    save()
    for round_no in range(1, args.rounds + 1):
        for count in args.connections:
            for name in frameworks[::1 if round_no % 2 else -1]:
                print(f"idle round={round_no} c={count} framework={name}", flush=True)
                row = {"framework": name, "round": round_no, "requested_connections": count, "established_connections": 0}
                with socket.socket() as probe:
                    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    probe.bind(("127.0.0.1", 8088))
                with tempfile.TemporaryFile() as log:
                    server = subprocess.Popen(manifest[name]["command"], env={**os.environ, **manifest[name].get("env", {})}, stdout=log, stderr=log)
                    connections = []
                    try:
                        deadline = time.monotonic() + 10
                        while True:
                            if server.poll() is not None:
                                raise RuntimeError("server startup failed")
                            try:
                                with socket.create_connection(("127.0.0.1", 8088), .2):
                                    break
                            except OSError:
                                if time.monotonic() >= deadline:
                                    raise
                                time.sleep(.02)
                        row["wire_checks"] = verify()
                        time.sleep(.2)
                        row["base"] = sample(server.pid)
                        started = time.monotonic()
                        for _ in range(count):
                            conn = http.client.HTTPConnection("127.0.0.1", 8088, timeout=5)
                            connections.append(conn)
                            conn.request("GET", "/plaintext")
                            response = conn.getresponse()
                            if response.status != 200 or response.read() != b"Hello, World!" or conn.sock is None:
                                raise RuntimeError("idle connection not retained with expected response")
                            row["established_connections"] += 1
                        row["establishment_seconds"] = time.monotonic() - started
                        initial = sample(server.pid)
                        started = time.monotonic()
                        samples = []
                        while time.monotonic() - started < args.seconds:
                            samples.append(sample(server.pid))
                            time.sleep(min(1, max(0, args.seconds - (time.monotonic() - started))))
                        final = sample(server.pid)
                        row.update(samples=samples, wall_seconds=time.monotonic() - started,
                                   cpu_percent=100 * (final["cpu_seconds"] - initial["cpu_seconds"]) / (time.monotonic() - started))
                        # Verify connections survived, outside the idle CPU interval.
                        for conn in connections:
                            conn.request("GET", "/plaintext")
                            response = conn.getresponse()
                            if response.status != 200 or response.read() != b"Hello, World!":
                                raise RuntimeError("idle connection failed subsequent request")
                        row["retention_checks"] = count
                    except Exception as error:
                        row["failure"] = repr(error)
                    finally:
                        # Keep clients open while timing idle shutdown. CPU-bound
                        # application drain is not tested by this scenario.
                        started = time.monotonic()
                        if server.poll() is None:
                            server.send_signal(signal.SIGINT)
                        try:
                            server.wait(timeout=10)
                        except subprocess.TimeoutExpired:
                            server.kill()
                            server.wait()
                            row["forced_runner_cleanup"] = True
                        row["shutdown_ms"] = (time.monotonic() - started) * 1000
                        for conn in connections:
                            conn.close()
                        row["server_exit"] = server.returncode
                        log.seek(0)
                        row["server_log"] = log.read().decode(errors="replace")
                        result["runs"].append(row)
                        save()


if __name__ == "__main__":
    main()
