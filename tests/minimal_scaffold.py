"""Default scaffold: minimal files, Native HTTP and Workers compilation."""
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time

cli = str(Path(sys.argv[1]).resolve())
checkout = str(Path(sys.argv[2]).resolve()) if len(sys.argv) == 3 else None
with tempfile.TemporaryDirectory(prefix="akamata-minimal-") as directory:
    root = Path(directory)
    subprocess.run([cli, "init", "minimalapp", "--target=both"], cwd=root, check=True)
    project = root / "minimalapp"
    source = (project / "src/main.zig").read_text()
    assert "fn hello() []const u8" in source
    assert "Note" not in source and "db.open" not in source
    assert not (project / "migrations").exists()
    assert not any((project / folder).exists() for folder in ["controllers", "services", "repositories", "providers"])
    build = ["zig", "build"] + ([f"--fork={checkout}"] if checkout else [])
    subprocess.run(build + ["-Doptimize=ReleaseSafe"], cwd=project, check=True)
    subprocess.run(build + ["-Dbackend=workers", "-Doptimize=ReleaseSafe"], cwd=project, check=True)
    with socket.socket() as reservation:
        reservation.bind(("127.0.0.1", 0))
        port = reservation.getsockname()[1]
    env = dict(os.environ, PORT=str(port))
    process = subprocess.Popen([str(project / "zig-out/bin/minimalapp")], cwd=project, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        deadline = time.monotonic() + 10
        while True:
            if process.poll() is not None:
                raise RuntimeError(f"minimal application exited: {process.returncode}")
            try:
                connection = socket.create_connection(("127.0.0.1", port), timeout=1)
                break
            except OSError:
                if time.monotonic() >= deadline:
                    raise
                time.sleep(0.05)
        with connection:
            connection.sendall(b"GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n")
            response = bytearray()
            while chunk := connection.recv(4096):
                response.extend(chunk)
        headers, body = bytes(response).split(b"\r\n\r\n", 1)
        assert headers.startswith(b"HTTP/1.1 200")
        assert body == b"Hello, minimalapp!", body
    finally:
        if process.poll() is None:
            process.send_signal(signal.SIGTERM)
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
    assert process.returncode == 0, process.returncode
print("minimal scaffold: Native HTTP/shutdown and Workers ReleaseSafe passed")
