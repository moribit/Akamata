#!/usr/bin/env python3
"""Durable serial matrix supervisor. No builds, tests or resource provisioning.

--launch owns a separate process session and a caffeinate assertion on macOS.
Check status.json instead of relying on an interactive terminal staying open.
--run is the foreground entry; --after-manifest contains already frozen binaries.
"""
import argparse
import fcntl
import json
import os
from pathlib import Path
import platform
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
RAW = ROOT / "benchmark-results/competitive/raw"
STATE = ROOT / ".zig-cache/competitive/supervisor"


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--launch", action="store_true")
    mode.add_argument("--run", action="store_true")
    parser.add_argument("--after-manifest", required=True)
    args = parser.parse_args()
    STATE.mkdir(parents=True, exist_ok=True)
    after = Path(args.after_manifest).resolve()
    if not after.is_file():
        parser.error("freeze the after binaries and create their manifest first")
    if args.launch:
        command = [sys.executable, str(Path(__file__).resolve()), "--run", "--after-manifest", str(after)]
        if platform.system() == "Darwin":
            command = ["caffeinate", "-i", *command]
        with (STATE / "supervisor.log").open("ab", buffering=0) as log:
            process = subprocess.Popen(command, cwd=ROOT, stdin=subprocess.DEVNULL, stdout=log,
                                       stderr=subprocess.STDOUT, start_new_session=True)
        print(json.dumps({"pid": process.pid, "status": str(STATE / "status.json"), "log": str(STATE / "supervisor.log")}))
        return
    lock = (STATE / "owner.lock").open("a+")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        raise SystemExit("a matrix supervisor already owns this run")
    child = None
    status = {"pid": os.getpid(), "started_unix": time.time(), "state": "running", "stages": []}

    def save():
        temporary = STATE / "status.tmp"
        temporary.write_text(json.dumps(status, indent=2) + "\n")
        temporary.replace(STATE / "status.json")

    def stop(signum, _):
        status["state"] = "interrupted"
        status["signal"] = signum
        if child is not None and child.poll() is None:
            child.send_signal(signal.SIGINT)
            child.wait(timeout=30)
        save()
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)
    stages = [
        (RAW / "baseline-manifest.json", RAW / "native-baseline.json", "framework-comparison.md"),
        (after, RAW / "native-after.json", "runtime-after-table.md"),
    ]
    save()
    try:
        for manifest, output, report in stages:
            stage = {"manifest": str(manifest), "output": str(output), "started_unix": time.time(), "state": "running"}
            status["stages"].append(stage)
            save()
            command = [sys.executable, "benchmark/competitive/scripts/measure.py", str(manifest), "--output", str(output), "--resume"]
            child = subprocess.Popen(command, cwd=ROOT)
            stage["child_pid"] = child.pid
            stage["command"] = command
            save()
            code = child.wait()
            child = None
            stage["exit"] = code
            stage["finished_unix"] = time.time()
            stage["state"] = "complete" if code == 0 else "failed"
            save()
            if code:
                raise RuntimeError(f"measurement exited {code}; checkpoint retained, no silent retry")
            table = subprocess.check_output([sys.executable, "benchmark/competitive/scripts/summarize.py", str(output)], cwd=ROOT, text=True)
            (RAW.parent / report).write_text(table)
        subprocess.run([sys.executable, "benchmark/competitive/scripts/compare_matrix.py",
                        str(RAW / "native-baseline.json"), str(RAW / "native-after.json"),
                        "--output", str(RAW.parent / "matrix-comparison.md")], cwd=ROOT, check=True)
        status["state"] = "complete"
    except Exception as error:
        status["state"] = "failed"
        status["failure"] = repr(error)
        raise
    finally:
        # Even a status/checkpoint write failure must not orphan a generator.
        if child is not None and child.poll() is None:
            child.send_signal(signal.SIGINT)
            try:
                child.wait(timeout=30)
            except subprocess.TimeoutExpired:
                child.kill()
                child.wait()
        status["finished_unix"] = time.time()
        save()


if __name__ == "__main__":
    main()
