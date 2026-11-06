#!/usr/bin/env python3
"""Same target twice: fresh local compiler cache, then warm; always run tests.
Tool/dependency global caches are deliberately retained. No network is required
when dependencies are already installed. Not a hosted-runner speed prediction.
"""
import json
import os
from pathlib import Path
import platform
import subprocess
import tempfile
import time

root = Path(__file__).resolve().parents[2]
out = root / "docs/evidence/ci-performance/raw/local"
out.mkdir(parents=True, exist_ok=True)
rows = []
with tempfile.TemporaryDirectory(prefix="akamata-ci-probe-") as cache:
    command = ["zig", "build", "guestbook-test", "-Doptimize=ReleaseSafe", "--summary", "all", "--cache-dir", cache]
    for name in ("fresh-local", "warm-local"):
        start = time.monotonic()
        result = subprocess.run(command, cwd=root, env=dict(os.environ, AKAMATA_CI_RERUN_TESTS="1"), capture_output=True, text=True)
        elapsed = time.monotonic() - start
        (out / (name + ".log")).write_text(result.stdout + result.stderr)
        result.check_returncode()
        assert "2/2 tests passed" in result.stderr
        assert "run test cached" not in result.stderr
        rows.append({"phase": name, "seconds": elapsed, "command": command, "returncode": result.returncode})
report = {"os": platform.platform(), "zig": subprocess.check_output(["zig", "version"], text=True).strip(),
          "sha": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(), "runs": rows}
(out / "compiler-probe.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report, indent=2))
