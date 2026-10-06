#!/usr/bin/env python3
"""Loopback Native runtime comparison; retain raw oha JSON and sampled RSS.

Usage: python3 tools/bench/runtime_compare.py BINARY OUTPUT.json [--rounds 3]
The server owns port 8080; the script never terminates unrelated processes.
"""
import argparse
import datetime
import hashlib
import json
import os
import platform
import signal
import socket
import statistics
import subprocess
import time
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("binary")
parser.add_argument("output")
parser.add_argument("--rounds", type=int, default=3)
parser.add_argument("--duration", default="5s")
args = parser.parse_args()
Path(args.output).parent.mkdir(parents=True, exist_ok=True)
with socket.socket() as probe:
    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    probe.bind(("127.0.0.1", 8080))
env = dict(os.environ)
env.pop("BENCH_OBSERVABILITY", None)
env.pop("BENCH_RUNTIME", None)
results = {"binary": args.binary, "duration": args.duration, "connections": 32, "runs": [],
           "recorded_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
           "platform": platform.platform(),
           "binary_sha256": hashlib.sha256(Path(args.binary).read_bytes()).hexdigest(),
           "oha_version": subprocess.check_output(["oha", "--version"], text=True).strip()}
server = subprocess.Popen([str(Path(args.binary).resolve())], env=env,
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    for _ in range(100):
        try:
            with socket.create_connection(("127.0.0.1", 8080), timeout=.1):
                break
        except OSError:
            if server.poll() is not None:
                raise RuntimeError("server exited during startup")
            time.sleep(.05)
    else:
        raise RuntimeError("server did not listen")
    # Warm SQLite/allocator paths before sampling.
    subprocess.run(["oha", "--no-tui", "--output-format", "quiet", "-n", "1000",
                    "-c", "32", "http://127.0.0.1:8080/db/1"], check=True)
    for round_no in range(args.rounds):
        for name, endpoint, extra in [
            ("hello", "/hello", []),
            ("echo", "/echo", ["-m", "POST", "-T", "application/json", "-d", '{"name":"x","n":42}']),
            ("db", "/db/1", []),
        ]:
            command = ["oha", "--no-tui", "--output-format", "json", "-c", "32", "-z", args.duration,
                       "-w", *extra, "http://127.0.0.1:8080" + endpoint]
            client = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            rss = []
            while client.poll() is None:
                sample = subprocess.check_output(["ps", "-o", "rss=", "-p", str(server.pid)], text=True)
                rss.append(int(sample.strip()))
                time.sleep(.1)
            stdout, stderr = client.communicate()
            if client.returncode:
                raise RuntimeError(stderr.decode())
            raw = json.loads(stdout)
            run = {"round": round_no + 1, "endpoint": name, "command": command,
                   "rss_mean_kib": statistics.mean(rss), "rss_peak_kib": max(rss), "oha": raw}
            results["runs"].append(run)
            success_rps = int(raw["statusCodeDistribution"].get("200", 0)) / raw["summary"]["total"]
            print(name, round_no + 1, "200 rps", round(success_rps), "RSS KiB", round(statistics.mean(rss)),
                  "errors", raw["errorDistribution"])
finally:
    server.send_signal(signal.SIGTERM)
    try:
        server.wait(timeout=15)
    except subprocess.TimeoutExpired:
        server.kill()
        server.wait()
        raise RuntimeError("server failed graceful shutdown")
Path(args.output).write_text(json.dumps(results, indent=2) + "\n")
