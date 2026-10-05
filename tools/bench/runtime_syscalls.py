#!/usr/bin/env python3
"""Linux strace attribution only; traced throughput is not benchmark evidence."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import signal
import socket
import subprocess
import time

p = argparse.ArgumentParser()
p.add_argument("binary")
p.add_argument("--output-dir", required=True)
p.add_argument("--endpoint", default="hello")
p.add_argument("--connections", type=int, default=32)
a = p.parse_args()
out = Path(a.output_dir)
out.mkdir(parents=True, exist_ok=True)
binary = Path(a.binary).resolve()
metadata = {"platform": platform.platform(), "binary_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(), "command": ["strace", "-f", "-c", "-o", str(out / "syscalls.txt"), str(binary)], "limitation": "ptrace changes scheduling and throughput; syscall counts cover startup/shutdown too"}
if platform.system() != "Linux":
    metadata["unsupported"] = "Linux strace collector"
else:
    with (out / "server.log").open("w") as log:
        proc = subprocess.Popen(metadata["command"], stderr=log, stdout=log, start_new_session=True)
        try:
            for _ in range(250):
                if proc.poll() is not None:
                    raise RuntimeError("strace/server startup failed")
                try:
                    with socket.create_connection(("127.0.0.1", 8080), .1):
                        break
                except OSError:
                    time.sleep(.02)
            else:
                raise RuntimeError("server readiness deadline")
            command = ["oha", "--no-tui", "--output-format", "json", "-c", str(a.connections), "-n", "10000", "-w", f"http://127.0.0.1:8080/{a.endpoint}"]
            if a.endpoint == "echo":
                command += ["-m", "POST", "-H", "content-type: application/json", "-d", '{"name":"hello","n":42}']
            metadata["load_command"] = command
            completed = subprocess.run(command, text=True, capture_output=True, timeout=90)
            metadata["load_exit_code"] = completed.returncode
            (out / "oha.json").write_text(completed.stdout)
            if completed.returncode:
                raise RuntimeError(completed.stderr)
        except Exception as exc:
            metadata["error"] = repr(exc)
        finally:
            if proc.poll() is None:
                os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=15)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait()
                metadata["error"] = "traced shutdown deadline"
            metadata["exit_code"] = proc.returncode
(out / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
if metadata.get("error"):
    raise SystemExit(metadata["error"])
