"""README/Getting Started: init, typed edit, dev, test and Native/Workers builds."""
from pathlib import Path
import os
import signal
import socket
import subprocess
import sys
import tempfile
import time

cli, checkout = (str(Path(arg).resolve()) for arg in sys.argv[1:3])
with tempfile.TemporaryDirectory(prefix="akamata-public-journey-") as temporary:
    root = Path(temporary).resolve()
    subprocess.run([cli, "init", "journey", "--target=both"], cwd=root, check=True)
    project = root / "journey"
    # Explicit test-local dependency ownership, never mutate the user's project.
    zon = project / "build.zig.zon"
    text = zon.read_text()
    import re
    dependency = os.path.relpath(checkout, project)
    text = re.sub(r'\.url = "[^"]+",\s*\.hash = "[^"]+",', f'.path = "{dependency}",', text)
    assert f'.path = "{dependency}"' in text
    zon.write_text(text)
    main = project / "src/main.zig"
    source = main.read_text().replace('.routes = .{ak.get("/", hello)}', '.routes = .{ak.get("/", hello), ak.post("/users", createUser)}')
    source += '''
const CreateUser = struct {
    name: []const u8,
    pub const validation = .{ .name = .{ak.model.rule.min_len(1)} };
};
fn createUser(input: ak.Json(CreateUser)) ak.Result(CreateUser, 201) {
    return ak.created(input.value);
}
test "typed application" {
    var app = try buildApplication(std.testing.allocator);
    defer app.deinit();
    var client = app.client(std.testing.allocator);
    var response = try client.post("/users").json(.{ .name = "Alice" }).send();
    defer response.deinit();
    try response.expectStatus(.created);
    try std.testing.expectEqualStrings("Alice", (try response.json(CreateUser)).name);
}
'''
    main.write_text(source)
    subprocess.run([cli, "test"], cwd=project, check=True)
    subprocess.run([cli, "check", "--quick"], cwd=project, check=True)
    subprocess.run(["zig", "build", "-Dbackend=workers", "-Doptimize=ReleaseSafe"], cwd=project, check=True)
    with socket.socket() as reserved:
        reserved.bind(("127.0.0.1", 0))
        port = reserved.getsockname()[1]
    env = dict(os.environ, PORT=str(port))
    log = root / "dev.log"
    with log.open("w") as output:
        process = subprocess.Popen([cli, "dev"], cwd=project, env=env, stdout=output, stderr=output)
        try:
            deadline = time.monotonic() + 120
            while True:
                if process.poll() is not None:
                    raise RuntimeError(log.read_text())
                try:
                    connection = socket.create_connection(("127.0.0.1", port), timeout=1)
                    break
                except OSError:
                    if time.monotonic() >= deadline:
                        raise RuntimeError(log.read_text())
                    time.sleep(.1)
            with connection:
                body = b'{"name":"Alice"}'
                connection.sendall(b"POST /users HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\nContent-Type: application/json\r\nContent-Length: " + str(len(body)).encode() + b"\r\n\r\n" + body)
                response = bytearray()
                while chunk := connection.recv(4096):
                    response.extend(chunk)
                assert response.startswith(b"HTTP/1.1 201"), response
                assert b'"Alice"' in response
        finally:
            process.send_signal(signal.SIGTERM)
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
                raise RuntimeError("dev did not shut down")
    assert process.returncode == 0, log.read_text()
print("public journey: init, typed JSON, dev HTTP/shutdown, CLI test/check, Workers build passed")
