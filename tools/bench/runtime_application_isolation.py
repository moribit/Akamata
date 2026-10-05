#!/usr/bin/env python3
"""Phase 6 prerequisite: real HTTP isolation and bounded application admission.

Default execution requires isolation and exits nonzero while the known blocker
persists. --record-blockers records that evidence without certifying readiness.
No benchmark optimization/certification runs should precede passing this gate.
"""
import argparse
import contextlib
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import signal
import socket
import subprocess
import sys
import tempfile
import time

sys.dont_write_bytecode = True
parser = argparse.ArgumentParser()
parser.add_argument("binary")
parser.add_argument("--output", required=True)
parser.add_argument("--record-blockers", action="store_true")
args = parser.parse_args()
binary = Path(args.binary).resolve()
spec = importlib.util.spec_from_file_location("contract", Path(__file__).parents[2] / "tests/transport_contract.py")
contract = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contract)
upgrade = b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
result = {
    "platform": platform.platform(),
    "zig_version": subprocess.check_output(["zig", "version"], text=True).strip(),
    "binary_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(),
    "command": sys.argv,
    "runs": [],
    "phase_6_complete": False,
}

@contextlib.contextmanager
def fixture(adapter, name, profile="stress"):
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0))
        port = probe.getsockname()[1]
    clients = []
    run = {"adapter": adapter, "scenario": name}
    def connect():
        client = contract.Client(port)
        clients.append(client)
        return client
    with tempfile.TemporaryFile() as log:
        proc = subprocess.Popen([str(binary), adapter, str(port), profile], stdout=log, stderr=log)
        try:
            for _ in range(100):
                if proc.poll() is not None:
                    raise AssertionError("fixture exited during startup")
                try:
                    c = connect()
                    c.send(contract.request(close=True))
                    assert c.response()[0] == 200
                    c.close()
                    break
                except ConnectionRefusedError:
                    time.sleep(.02)
            else:
                raise AssertionError("startup deadline")
            yield connect, run
        finally:
            started = time.monotonic()
            if proc.poll() is None:
                proc.send_signal(signal.SIGTERM)
                try:
                    proc.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
                    raise AssertionError("bounded I/O shutdown failed")
            run["shutdown_ms"] = (time.monotonic() - started) * 1000
            for c in clients:
                c.close()
            log.seek(0)
            text = log.read().decode(errors="replace")
            assert proc.returncode == 0, text
            assert "memory address" not in text, text
            stats_line = next(line for line in text.splitlines() if "BENCH_STATS " in line)
            stats = json.loads(stats_line.split("BENCH_STATS ", 1)[1])
            assert stats["live"] == 0, stats
            run["allocator"] = stats
            result["runs"].append(run)

def http_probe(connect):
    client = connect()
    client.sock.settimeout(.25)
    started = time.monotonic()
    client.send(contract.request(close=True))
    try:
        isolated = client.response()[0] == 200
    except (TimeoutError, ConnectionResetError, AssertionError):
        isolated = False
    return isolated, (time.monotonic() - started) * 1000

try:
    host = "epoll" if platform.system() == "Linux" else "kqueue"
    for adapter in ("threaded", host):
        for scenario, paths in (
            ("four-idle-upgrades", ["/upgrade-wait"] * 4),
            ("four-slow-streams", ["/large"] * 4),
            ("mixed-upgrade-stream", ["/upgrade-wait"] * 2 + ["/large"] * 2),
        ):
            with fixture(adapter, scenario) as (connect, run):
                held = []
                for path in paths:
                    c = connect()
                    held.append(c)
                    c.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
                    c.send(contract.request(path, extra=upgrade if "upgrade" in path else b""))
                    # Read just the handshake/headers, never the 16 MiB body.
                    while b"\r\n\r\n" not in c.pending:
                        chunk = c.sock.recv(1024)
                        assert chunk, "closed before handoff"
                        c.pending += chunk
                    assert c.pending.startswith(b"HTTP/1.1 " + (b"101" if "upgrade" in path else b"200"))
                time.sleep(.03)
                run["http_isolated"], run["probe_ms"] = http_probe(connect)
                if adapter == "threaded":
                    assert run["http_isolated"], run
                # Keep borrowed clients live through forced drain in finally.
        with fixture(adapter, "application-queue-overflow-recovery", "admission") as (connect, run):
            owner = connect()
            owner.send(contract.request("/upgrade-wait", extra=upgrade))
            assert owner.response()[0] == 101
            queued = connect()
            queued.send(contract.request(close=True))
            time.sleep(.05)
            rejected = connect()
            rejected.send(contract.request(close=True))
            if adapter == host:
                rejected.eof()
                run["overflow_closed_without_response"] = True
            else:
                assert rejected.response()[0] == 200
                run["threaded_option_ignored"] = True
            owner.close()
            assert queued.response()[0] == 200
            isolated, _ = http_probe(connect)
            assert isolated, run
            run["admission_recovered"] = True
    isolation = [r["http_isolated"] for r in result["runs"] if "http_isolated" in r]
    result["isolation_passed"] = all(isolation)
    result["note"] = "Passing isolation alone does not complete Phase 6: incremental lifecycle/ownership and fairness parity are also required."
finally:
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    Path(args.output).write_text(json.dumps(result, indent=2) + "\n")

if not result["isolation_passed"] and not args.record_blockers:
    raise SystemExit("Phase 6 incomplete: synchronous upgrade/stream still owns workers; retain gate, do not begin Phase 7 optimization.")
print("application isolation evidence saved; phase_6_complete=false")
