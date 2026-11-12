"""Manual Python measurement/reporting clients use the tested Zig guards.

Build `zig build ci-runner` before measuring. Never compile or provision a tool
from inside a measured interval. This module contains no test assertions.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile


def query(operation, *documents, arguments=(), raw=False):
    root = Path(__file__).resolve().parents[3]
    binary = Path(os.environ.get("AKAMATA_BENCHMARK_TOOL", root / "zig-out/bin/akamata-tests"))
    if not binary.is_file():
        raise RuntimeError("native benchmark guards missing; run zig build ci-runner before measuring")
    with tempfile.TemporaryDirectory(prefix="akamata-evidence-") as directory:
        paths = []
        for index, document in enumerate(documents):
            path = Path(directory) / f"input-{index}.json"
            path.write_text(document if isinstance(document, str) else json.dumps(document))
            paths.append(str(path))
        result = subprocess.run([str(binary), "evidence", operation, *paths, *map(str, arguments)],
                                capture_output=True, text=True)
        if result.returncode:
            raise ValueError(result.stderr.strip())
        return result.stdout if raw else json.loads(result.stdout or "{}")
