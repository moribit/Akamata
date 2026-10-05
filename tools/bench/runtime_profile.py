#!/usr/bin/env python3
"""Sample owned benchmark children during /db load; sampling is not timing data."""
import argparse
import os
import signal
import socket
import subprocess
import time
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("binaries", nargs="+")
p.add_argument("--output-dir", required=True)
a = p.parse_args()
directory = Path(a.output_dir)
directory.mkdir(parents=True, exist_ok=True)
for entry in a.binaries:
    label, binary = entry.split("=", 1)
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
        client = subprocess.Popen(["oha", "--no-tui", "--output-format", "quiet", "-c", "32", "-z", "10s", "-w", "http://127.0.0.1:8080/db/1"])
        time.sleep(2)
        subprocess.run(["sample", str(server.pid), "5", "1", "-file", str(directory / (label + ".sample.txt"))], check=True)
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
