#!/usr/bin/env python3
"""Diagnostic shutdown probe with a budget longer than Native's 30 s drain."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import resource
import signal
import socket
import subprocess
import tempfile
import time
from measure import load, sample, verify

p = argparse.ArgumentParser()
p.add_argument("manifest")
p.add_argument("--framework", default="threaded")
p.add_argument("--output", required=True)
a = p.parse_args()
out = Path(a.output)
if out.exists():
    p.error("refusing to overwrite probe evidence")
definition = json.loads(Path(a.manifest).read_text())[a.framework]
soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
resource.setrlimit(resource.RLIMIT_NOFILE, (max(soft, min(4096, hard)), hard))
result = {"classification": "shutdown-diagnostic", "command": __import__("sys").argv,
          "os": platform.platform(), "binary": definition,
          "sha256": hashlib.sha256(Path(definition["command"][0]).read_bytes()).hexdigest()}
with socket.socket() as probe:
    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    probe.bind(("127.0.0.1", 8088))
with tempfile.TemporaryFile() as log, tempfile.TemporaryDirectory() as directory:
    body = Path(directory) / "body.bin"
    body.write_bytes(b"x" * 65536)
    server = subprocess.Popen(definition["command"], env={**os.environ, **definition.get("env", {})}, stdout=log, stderr=log)
    try:
        deadline = time.monotonic() + 10
        while True:
            if server.poll() is not None:
                raise RuntimeError("startup failed")
            try:
                with socket.create_connection(("127.0.0.1", 8088), .2): pass
                break
            except OSError:
                if time.monotonic() >= deadline: raise
                time.sleep(.02)
        result["wire_checks"] = verify()
        def command(seconds):
            return ["oha", "--no-tui", "--output-format", "json", "--http-version", "1.1", "-c", "1024", "-z", f"{seconds}s", "-t", "10s", "-w", "-m", "POST", "-T", "application/octet-stream", "-D", str(body), "http://127.0.0.1:8088/echo"]
        result["warmup"] = load(command(2), server, 2)
        result["load"] = load(command(5), server, 5)
        result["drain_samples"] = []
        started = time.monotonic()
        server.send_signal(signal.SIGINT)
        sampled = False
        while server.poll() is None:
            elapsed = time.monotonic() - started
            if elapsed > 45:
                server.kill()
                result["forced_cleanup"] = True
                break
            try:
                result["drain_samples"].append({"seconds": elapsed, **sample(server.pid)})
            except (subprocess.CalledProcessError, IndexError):
                if server.poll() is None: raise
            if platform.system() == "Darwin" and elapsed > 3 and not sampled:
                sampled = True
                target = out.with_suffix(".sample.txt")
                probe = subprocess.run(["sample", str(server.pid), "1", "-file", str(target), "-mayDie"], capture_output=True, text=True)
                result["wall_stack_sample"] = {"path": str(target), "exit": probe.returncode, "stderr": probe.stderr}
            try:
                server.wait(timeout=1)
            except subprocess.TimeoutExpired:
                pass
        server.wait()
        result["shutdown_ms"] = (time.monotonic() - started) * 1000
    except BaseException as error:
        result["failure"] = repr(error)
        raise
    finally:
        if server.poll() is None:
            server.kill(); server.wait()
        result["server_exit"] = server.returncode
        log.seek(0)
        result["server_log"] = log.read().decode(errors="replace")
        out.write_text(json.dumps(result, indent=2) + "\n")
print("shutdown probe", result["shutdown_ms"], "ms; exit", result["server_exit"])
