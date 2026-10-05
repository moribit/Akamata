#!/usr/bin/env python3
"""Sample owned benchmark children during /db load; sampling is not timing data."""
import argparse
import hashlib
import json
import platform
import shutil
import os
import signal
import socket
import subprocess
import time
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("binaries", nargs="+")
p.add_argument("--output-dir", required=True)
p.add_argument("--endpoint", default="db/1")
p.add_argument("--connections", type=int, nargs="+", default=[32])
a = p.parse_args()
directory = Path(a.output_dir)
directory.mkdir(parents=True, exist_ok=True)
metadata = {"platform": platform.platform(), "oha_version": subprocess.check_output(["oha", "--version"], text=True).strip(), "command": __import__("sys").argv, "runs": []}
for connections in a.connections:
 for entry in a.binaries:
    label, binary = entry.split("=", 1)
    run = {"label": label, "connections": connections, "binary_sha256": hashlib.sha256(Path(binary).read_bytes()).hexdigest()}
    stem = label if a.connections == [32] else label + "-c" + str(connections)
    with socket.socket() as probe:
        probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        probe.bind(("127.0.0.1", 8080))
        probe.listen(1)
    env = dict(os.environ)
    for key in ("BENCH_STATS", "BENCH_RUNTIME", "BENCH_OBSERVABILITY"):
        env.pop(key, None)
    server = subprocess.Popen([str(Path(binary).resolve())], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    client = None
    try:
        for _ in range(100):
            try:
                with socket.create_connection(("127.0.0.1", 8080), .2):
                    break
            except OSError:
                time.sleep(.02)
        else:
            raise RuntimeError("startup deadline")
        client = subprocess.Popen(["oha", "--no-tui", "--output-format", "quiet", "-c", str(connections), "-z", "10s", "-w", "http://127.0.0.1:8080/" + a.endpoint])
        time.sleep(2)
        if platform.system() == "Darwin":
            command = ["sample", str(server.pid), "5", "1", "-file", str(directory / (stem + ".sample.txt"))]
            subprocess.run(command, check=True)
            run["profile_command"] = command
            run["profile_available"] = True
        elif shutil.which("perf"):
            command = ["perf", "record", "-F", "199", "-p", str(server.pid), "-g", "-o", str(directory / (stem + ".perf.data")), "--", "sleep", "5"]
            collected = subprocess.run(command, capture_output=True, text=True)
            run.update(profile_command=command, profile_available=collected.returncode == 0, profiler_stderr=collected.stderr)
            if collected.returncode == 0:
                report = subprocess.run(["perf", "report", "--stdio", "--no-children", "-i", str(directory / (stem + ".perf.data"))], capture_output=True, text=True)
                (directory / (stem + ".perf.txt")).write_text(report.stdout + report.stderr)
        else:
            run.update(profile_available=False, reason="perf is unavailable on this runner")
        client.wait(timeout=15)
        if client.returncode:
            raise RuntimeError("profile workload failed")
    finally:
        if client is not None and client.poll() is None:
            client.terminate()
            client.wait(timeout=5)
        server.send_signal(signal.SIGTERM)
        try:
            server.wait(timeout=15)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait()
            raise RuntimeError("profile server shutdown deadline")

    metadata["runs"].append(run)
    (directory / "profile-metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
