#!/usr/bin/env python3
"""Compile the learning path and exercise actual Workers artifacts offline.

Zig 0.17.0, Node 24 (JSPI), Python 3; optional AKAMATA_DX_TSC points to
TypeScript 5.9.3 tsc.js. No credentials, remote resources or listening sockets.
"""
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sqlite3
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
ZIG = os.environ.get("ZIG", "zig")
EXAMPLES = ("guestbook", "tasks", "chat", "device_messaging")
REPORT = ROOT / ".zig-cache/living-examples.json"
results = []


def run(*args, **kwargs):
    start = time.monotonic()
    result = subprocess.run(args, cwd=ROOT, capture_output=True, text=True, **kwargs)
    if result.returncode:
        print(result.stdout)
        print(result.stderr)
        result.check_returncode()
    results.append({"command": list(args), "seconds": round(time.monotonic() - start, 3)})
    return result.stdout


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    evidence = {"os": platform.platform(), "zig": run(ZIG, "version").strip(),
                "node": run("node", "--version").strip(),
                "commit": run("git", "rev-parse", "HEAD").strip(),
                "evidence": "Native application + actual WASM/managed JSPI/offline host; not live Cloudflare",
                "artifacts": [], "commands": results}
    with tempfile.TemporaryDirectory(prefix="akamata-living-") as directory:
        output = Path(directory)
        for mode in ("Debug", "ReleaseSafe"):
            run(ZIG, "build", "guestbook-test", "tasks-test", "chat-test", f"-Doptimize={mode}")
            for example in EXAMPLES:
                run(ZIG, "build", f"-Dexample={example}", f"-Doptimize={mode}")
                binary = ROOT / "zig-out/bin" / example
                evidence["artifacts"].append({"example": example, "target": "native", "mode": mode, "sha256": sha(binary)})
        migration_db = output / "migration.sqlite"
        environment = dict(os.environ, DATABASE_URL="file:" + str(migration_db))
        binary = str(ROOT / "zig-out/bin/device_messaging")
        run(binary, "migrate-up", env=environment)
        run(binary, "migrate-up", env=environment)
        with sqlite3.connect(migration_db) as connection:
            assert connection.execute("SELECT count(*) FROM schema_migrations").fetchone()[0] == 1
            assert connection.execute("SELECT count(*) FROM portable_records").fetchone()[0] == 0
        evidence["versioned_migration"] = "two invocations; one history entry"
        for example in EXAMPLES:
            readme = (ROOT / "examples" / example / "README.md").read_text()
            for section in ("What you will learn", "Why this example exists", "Run Native", "Test", "Architecture", "Next"):
                assert "## " + section in readme, (example, section)
        evidence["native_wire"] = json.loads(run("python3", "tests/living_chat.py"))
        for example in EXAMPLES:
            binary = str(ROOT / "zig-out/bin" / example)
            schema = output / f"{example}.sql"
            schema.write_text(run(binary, "--print-schema"))
            for target in ("native", "workers"):
                manifest = json.loads(run(binary, "akamata-capabilities", target))
                assert manifest, (example, target)
            if example != "device_messaging":
                document = json.loads(run(binary, "akamata-openapi"))
                assert document["paths"], example
                client = output / f"{example}.ts"
                client.write_text(run(binary, "akamata-client"))
                typecheck(client)
            if example in ("chat", "device_messaging"):
                protocol = output / f"{example}-protocol.ts"
                protocol.write_text(run(binary, "akamata-protocol-ts"))
                typecheck(protocol)
                header = output / f"{example}-protocol.c"
                header.write_text(run(binary, "akamata-protocol-c"))
                run(ZIG, "cc", "-c", str(header), "-o", str(output / f"{example}-protocol.o"))
            run(ZIG, "build", f"-Dexample={example}", "-Dbackend=workers", "-Doptimize=ReleaseSafe")
            artifact = ROOT / "zig-out/bin" / f"{example}_worker.wasm"
            host = json.loads(run("node", "--experimental-wasm-jspi", "tests/living_workers.mjs", example, str(artifact), str(schema)))
            evidence["artifacts"].append({"example": example, "target": "workers", "sha256": sha(artifact), "host": host})
        run(ZIG, "build", "documentation-test", "-Doptimize=ReleaseSafe")
        run("node", "--test", "tests/workers_wasm_dispatch_test.mjs")
        run("python3", "tests/documentation_links.py")
        run(ZIG, "fmt", "--check", "examples", "tests/docs/minimal.zig")
        assert (ROOT / "deploy/worker/index.mjs").read_bytes() == (ROOT / "tools/akamata/src/templates/worker_index.mjs.tpl").read_bytes()
        assert (ROOT / "examples/chat/src/schema.sql").read_bytes() == (ROOT / "deploy/worker/d1_schema.sql").read_bytes()
    REPORT.parent.mkdir(exist_ok=True)
    REPORT.write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"Living reference passed: {len(results)} commands; evidence: {REPORT}")


def typecheck(path):
    compiler = os.environ.get("AKAMATA_DX_TSC")
    if compiler:
        run("node", compiler, "--strict", "--noEmit", "--target", "ES2022", "--lib", "ES2022,DOM", str(path))


if __name__ == "__main__":
    main()
