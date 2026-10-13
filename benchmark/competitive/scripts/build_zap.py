#!/usr/bin/env python3
"""Mirror upstream v0.11.0 C flags without its unsupported macOS-27 build runner.

No zap source modifications. Uses the upstream-compatible Zig 0.15.2 compiler;
an existing macOS 15.4 SDK is explicit for linking both the library and executable.
"""
import json
import os
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[3]
source = root / ".zig-cache/competitive/zap"
project = root / "benchmark/competitive/zap"
zig = os.environ.get("ZAP_ZIG", "/Users/mimoc/.zvm/0.15.2/zig")
sdk = os.environ.get("ZAP_SDK", "/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk")
if not source.exists():
    source.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["git","clone","--depth","1","--branch","v0.11.0","https://github.com/zigzap/zap.git",str(source)],check=True)
sha = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=source, text=True).strip()
assert sha == "66c5dc42c781bbb8a9100afda3c7e69ee96eddf3"
out = project / "zig-out"
(out / "lib").mkdir(parents=True, exist_ok=True)
(out / "bin").mkdir(parents=True, exist_ok=True)
base = source / "facil.io"
files = ["fio.c", "fio_zig.c", "http/http.c", "http/http1.c", "http/websockets.c", "http/http_internal.c",
         "fiobj/fiobj_numbers.c", "fiobj/fio_siphash.c", "fiobj/fiobj_str.c", "fiobj/fiobj_ary.c", "fiobj/fiobj_data.c",
         "fiobj/fiobj_hash.c", "fiobj/fiobj_json.c", "fiobj/fiobject.c", "fiobj/fiobj_mustache.c", "cli/fio_cli.c"]
includes = [base, *(base / "lib/facil" / p for p in (".", "fiobj", "cli", "http", "http/parsers"))]
commands = [
    [zig, "build-lib", "-OReleaseFast", "-dynamic", "-lc", "-target", "aarch64-macos.15.0", "-L", sdk + "/usr/lib",
     *[item for path in includes for item in ("-I", str(path))], "-cflags", "-Os", "-Wno-return-type-c-linkage", "-fno-sanitize=undefined", "-DFIO_HTTP_EXACT_LOGGING", "--",
     *[str(base / "lib/facil" / path) for path in files], "-femit-bin=" + str(out / "lib/libfacil.dylib")],
    [zig, "build-exe", "-OReleaseFast", "-lc", "-target", "aarch64-macos.15.0", "-L", sdk + "/usr/lib",
     "-L", str(out / "lib"), "-lfacil", "-rpath", str(out / "lib"), "-L", str(root / "benchmark/competitive/fixtures"), "-lcompetitive_sqlite",
     "--dep", "zap", "-Mroot=" + str(project / "main.zig"), "-Mzap=" + str(source / "src/zap.zig"),
     "-femit-bin=" + str(out / "bin/competitive-zap")],
]
for command in commands:
    subprocess.run(command, check=True)
print(json.dumps({"zap_source": sha, "compiler": zig, "sdk": sdk, "commands": commands}, indent=2))
