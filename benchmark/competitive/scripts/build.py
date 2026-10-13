#!/usr/bin/env python3
"""Build serially, never during measurement. Lockfiles are part of the fixture."""
import argparse
import json
import os
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[3]
base = root / "benchmark/competitive"
zig = os.environ.get("COMPETITIVE_ZIG", "zig")
parser = argparse.ArgumentParser()
parser.add_argument("frameworks", nargs="*", default=["akamata", "actix", "axum", "go"])
args = parser.parse_args()
commands = []
def run(argv, cwd=root):
    commands.append({"command": argv, "cwd": str(cwd)})
    subprocess.run(argv, cwd=cwd, check=True)

if any(f in args.frameworks for f in ("actix", "axum", "go", "zap")):
    flags = ["-O3", "-DSQLITE_THREADSAFE=1", "-DSQLITE_DQS=0", "-DSQLITE_OMIT_LOAD_EXTENSION", "-DSQLITE_DEFAULT_FOREIGN_KEYS=1", "-DSQLITE_USE_URI=1", "-std=c99", "-Ithird_party/sqlite"]
    run([zig, "cc", *flags, "-c", "third_party/sqlite/sqlite3.c", "-o", str(base / "fixtures/sqlite.o")])
    run([zig, "cc", *flags, "-c", str(base / "fixtures/sqlite.c"), "-o", str(base / "fixtures/glue.o")])
    run([zig, "ar", "rcs", str(base / "fixtures/libcompetitive_sqlite.a"), str(base / "fixtures/sqlite.o"), str(base / "fixtures/glue.o")])
for framework in args.frameworks:
    if framework == "akamata":
        run([zig, "build", "competitive-bench", "-Doptimize=ReleaseFast", "-j2"])
    elif framework in ("actix", "axum"):
        run(["cargo", "build", "--release", "--locked"], base / framework)
    elif framework == "go":
        run(["go", "build", "-trimpath", "-o", "competitive-go", "."], base / "go")
    else:
        raise SystemExit("Use the separately pinned zap toolchain and documented build; do not silently port it.")
print(json.dumps({"builds": commands}, indent=2))
