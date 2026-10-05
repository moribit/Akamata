#!/usr/bin/env python3
"""Repeat a selected Contract with live failure diagnostics; never relax it."""
import argparse
import contextlib
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import sys
import unittest

sys.dont_write_bytecode = True
p = argparse.ArgumentParser()
p.add_argument("binary")
p.add_argument("--adapter", choices=["threaded", "kqueue", "epoll"], required=True)
p.add_argument("--test", default="test_upgrade_hub_snapshot_disconnect_ownership")
p.add_argument("--repeats", type=int, default=30)
p.add_argument("--output", required=True)
a = p.parse_args()
if not 1 <= a.repeats <= 100:
    p.error("bounded repeat count must be 1..100")
sys.argv = [sys.argv[0], a.binary]
spec = importlib.util.spec_from_file_location("contract", Path(__file__).resolve().parents[2] / "tests/transport_contract.py")
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
result = {"platform": platform.platform(), "binary_sha256": hashlib.sha256(Path(a.binary).read_bytes()).hexdigest(), "adapter": a.adapter, "test": a.test, "requested_repeats": a.repeats, "runs": []}
original = c.Contract.server

@contextlib.contextmanager
def diagnostic_server(self, profile="default"):
    with original(self, profile) as pair:
        try:
            yield pair
        except Exception as exc:
            snapshot = {"error": repr(exc)}
            try:
                client = pair[1]()
                client.send(c.request("/stats", close=True))
                snapshot["stats"] = client.response()[2].decode()
                client.close()
            except Exception as error:
                snapshot["snapshot_error"] = repr(error)
            result.setdefault("failure_snapshots", []).append(snapshot)
            raise

c.Contract.server = diagnostic_server
kind = type("RepeatedContract", (c.Contract,), {"adapter": a.adapter})
for repeat in range(a.repeats):
    run = unittest.TextTestRunner(verbosity=1).run(unittest.TestSuite([kind(a.test)]))
    result["runs"].append({"repeat": repeat + 1, "passed": run.wasSuccessful(), "errors": [text for _, text in run.errors], "failures": [text for _, text in run.failures]})
    Path(a.output).parent.mkdir(parents=True, exist_ok=True)
    Path(a.output).write_text(json.dumps(result, indent=2) + "\n")
    if not run.wasSuccessful():
        raise SystemExit(1)
