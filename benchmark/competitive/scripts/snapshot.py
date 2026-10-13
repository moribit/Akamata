#!/usr/bin/env python3
"""Freeze executables before optimizing; never overwrite an old baseline."""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("manifest")
parser.add_argument("destination")
parser.add_argument("--output", required=True)
args = parser.parse_args()
manifest = json.loads(Path(args.manifest).read_text())
destination = Path(args.destination)
destination.mkdir(parents=True, exist_ok=False)
frozen = {}
for name, definition in manifest.items():
    assert re.fullmatch(r"[A-Za-z0-9_-]+", name)
    executable = Path(definition["command"][0])
    target = destination / name
    shutil.copy2(executable, target)
    assert hashlib.sha256(executable.read_bytes()).digest() == hashlib.sha256(target.read_bytes()).digest()
    frozen[name] = {**definition, "command": [str(target), *definition["command"][1:]],
                    "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()}
output = Path(args.output)
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(frozen, indent=2) + "\n")
print("Frozen", len(frozen), "executables in", destination)
