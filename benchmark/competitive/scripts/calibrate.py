#!/usr/bin/env python3
"""Generator calibration, not a framework ranking or certification matrix.

Compare one versus two oha processes at the same TOTAL connection count.
Keep individual latency distributions: averaging percentiles is invalid.
"""
import argparse
import hashlib
import json
import os
import platform
import signal
import socket
import statistics
import subprocess
import tempfile
import time
from pathlib import Path

from measure import sample, verify


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest")
    parser.add_argument("--output", required=True)
    parser.add_argument("--frameworks", nargs="+", default=["akamata-threaded", "axum"])
    parser.add_argument("--connections", type=int, default=32)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--warmup", type=int, default=10)
    parser.add_argument("--duration", type=int, default=30)
    args = parser.parse_args()
    if args.connections < 2 or args.connections % 2 or args.connections > 1024:
        parser.error("connections must be even, between 2 and 1024")
    manifest = json.loads(Path(args.manifest).read_text())
    output = Path(args.output)
    if output.exists():
        parser.error("refusing to overwrite calibration evidence")
    output.parent.mkdir(parents=True, exist_ok=True)
    result = {"classification": "generator-calibration", "command": __import__("sys").argv,
              "os": platform.platform(), "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
              "oha": subprocess.check_output(["oha", "--version"], text=True).strip(),
              "binaries": {name: {**manifest[name], "sha256": hashlib.sha256(Path(manifest[name]["command"][0]).read_bytes()).hexdigest()} for name in args.frameworks},
              "runs": []}
    def save():
        tmp = output.with_suffix(".tmp")
        tmp.write_text(json.dumps(result, indent=2) + "\n")
        tmp.replace(output)
    save()
    for round_no in range(1, args.rounds + 1):
        # Alternate order to reduce systematic thermal/order bias.
        for name in args.frameworks[::1 if round_no % 2 else -1]:
            for generators in ([1, 2] if round_no % 2 else [2, 1]):
                print(f"calibration round={round_no} framework={name} generators={generators}", flush=True)
                row = {"framework": name, "round": round_no, "generators": generators,
                       "total_connections": args.connections, "warmup_seconds": args.warmup, "duration_seconds": args.duration}
                with socket.socket() as probe:
                    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    probe.bind(("127.0.0.1", 8088))
                with tempfile.TemporaryFile() as log:
                    server = subprocess.Popen(manifest[name]["command"], env={**os.environ, **manifest[name].get("env", {})}, stdout=log, stderr=log)
                    clients = []
                    files = []
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
                        for seconds, phase in [(args.warmup, "warmup"), (args.duration, "measurement")]:
                            if not seconds:
                                continue
                            commands = [["oha", "--no-tui", "--output-format", "json", "--http-version", "1.1", "-c", str(args.connections // generators), "-z", f"{seconds}s", "-t", "10s", "-w", "http://127.0.0.1:8088/plaintext"] for _ in range(generators)]
                            initial = sample(server.pid)
                            started = time.monotonic()
                            files = [tempfile.TemporaryFile() for _ in commands]
                            clients = [subprocess.Popen(command, stdout=file, stderr=file) for command, file in zip(commands, files)]
                            samples = []
                            while any(client.poll() is None for client in clients):
                                if server.poll() is not None or time.monotonic() - started > seconds + 60:
                                    raise RuntimeError("server failed or generator exceeded bounded drain")
                                generator_samples = []
                                for client in clients:
                                    if client.poll() is None:
                                        try:
                                            generator_samples.append(sample(client.pid))
                                        except (subprocess.CalledProcessError, IndexError, FileNotFoundError):
                                            if client.poll() is None:
                                                raise
                                samples.append({"server": sample(server.pid), "generators": generator_samples})
                                try:
                                    next((client for client in clients if client.poll() is None), clients[0]).wait(timeout=1)
                                except subprocess.TimeoutExpired:
                                    pass
                            elapsed = time.monotonic() - started
                            final = sample(server.pid)
                            records = []
                            for client, file in zip(clients, files):
                                file.seek(0)
                                text = file.read().decode()
                                if client.wait() != 0:
                                    raise RuntimeError(f"oha failed: {text}")
                                records.append(json.loads(text))
                                file.close()
                            files = []
                            row[phase] = {"commands": commands, "individual_oha": records,
                                          "wall_seconds": elapsed, "process_samples": samples,
                                          "server_cpu_percent": 100 * (final["cpu_seconds"] - initial["cpu_seconds"]) / elapsed,
                                          "server_rss_mean_kib": statistics.mean(s["server"]["rss_kib"] for s in samples)}
                    except Exception as error:
                        row["failure"] = str(error)
                        raise
                    finally:
                        for client in clients:
                            if client.poll() is None:
                                client.kill()
                            client.wait()
                        for file in files:
                            file.close()
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
                        row["server_exit"] = server.returncode
                        log.seek(0)
                        row["server_log"] = log.read().decode(errors="replace")
                        result["runs"].append(row)
                        save()


if __name__ == "__main__":
    main()
