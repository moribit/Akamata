"""Opt-in CI command timing; no change to subprocess output or failure behavior."""
import json
import os
from pathlib import Path
import resource
import subprocess
import sys
import time


def run(*args, label="scaffold-minimal", **kwargs):
    start = time.monotonic()
    before = resource.getrusage(resource.RUSAGE_CHILDREN)
    code = None
    try:
        result = subprocess.run(*args, **kwargs)
        code = result.returncode
        return result
    finally:
        directory = os.environ.get("AKAMATA_CI_TIMING_DIR")
        if directory:
            after = resource.getrusage(resource.RUSAGE_CHILDREN)
            row = {"command": list(args[0]), "seconds": time.monotonic() - start,
                   "child_cpu_seconds": after.ru_utime + after.ru_stime - before.ru_utime - before.ru_stime,
                   "returncode": code}
            path = Path(directory)
            path.mkdir(parents=True, exist_ok=True)
            # Separate files for the two concurrently run scaffold suites.
            with (path / (label + ".jsonl")).open("a") as stream:
                stream.write(json.dumps(row) + "\n")


if __name__ == "__main__":
    sys.exit(run(sys.argv[2:], label=sys.argv[1]).returncode)
