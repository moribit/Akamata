#!/usr/bin/env python3
"""Serial localhost validation; never run load cases concurrently with builds.

Run after building/copying the before and after HTTP fixtures. Every round and
binary digest is retained by runtime_matrix.py. No remote resource is used.
"""
import argparse
import datetime
import json
import subprocess
import sys
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("before")
p.add_argument("after")
p.add_argument("--output-dir", default="benchmark-results/v0.2.1")
p.add_argument("--only", nargs="+")
a = p.parse_args()
directory = Path(a.output_dir)
directory.mkdir(parents=True, exist_ok=True)
cases = [
    ("final-paired", ["--connections", "32", "128", "512", "1024", "--idle", "32", "128", "512", "1024", "--modes", "keep_alive"]),
    ("paired-allocations", ["--connections", "32", "--idle", "32", "--stats", "--modes", "keep_alive"]),
    ("paired-observability", ["--connections", "32", "--idle", "32", "--observability", "metrics", "--modes", "keep_alive"]),
    ("paired-large-json", ["--connections", "32", "--idle", "32", "--endpoints", "echo", "--echo-bytes", "65536", "--stats", "--modes", "keep_alive"]),
    ("paired-short-lived", ["--connections", "32", "128", "512", "1024", "--skip-idle", "--modes", "short_lived", "--short-qps", "500"]),
    ("db-contention-repeat", ["--connections", "512", "--idle", "32", "--endpoints", "db/1", "--duration", "10s", "--modes", "keep_alive"]),
]
if a.only and set(a.only) - {name for name, _ in cases}:
    p.error("unknown case")
manifest_path = directory / "validation-commands.json"
manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else []
for name, extra in cases:
    if a.only and name not in a.only:
        continue
    command = [sys.executable, "tools/bench/runtime_matrix.py", "before=" + a.before,
               "after=" + a.after, "--output", str(directory / (name + ".json")),
               "--rounds", "3", "--duration", "3s", *extra]
    record = {"case": name, "command": command,
              "started": datetime.datetime.now(datetime.timezone.utc).isoformat()}
    print("Starting", name, flush=True)
    result = subprocess.run(command)
    record["exit_code"] = result.returncode
    manifest.append(record)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    result.check_returncode()
