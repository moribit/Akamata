#!/usr/bin/env python3
"""Dedicated loopback Native chat wire test; no remote host or credentials."""
import json
import os
from pathlib import Path
import signal
import socket
import struct
import subprocess
import tempfile
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


def exact(sock, count):
    result = b""
    while len(result) < count:
        part = sock.recv(count - len(result))
        if not part:
            raise EOFError("WebSocket disconnected")
        result += part
    return result


def connect(port, room, user):
    sock = socket.create_connection(("127.0.0.1", port), timeout=5)
    sock.sendall((f"GET /realtime/{room}?user={user} HTTP/1.1\r\nHost: localhost\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n\r\n").encode())
    header = b""
    while not header.endswith(b"\r\n\r\n"):
        header += exact(sock, 1)
        assert len(header) < 8192
    assert header.startswith(b"HTTP/1.1 101"), header
    return sock


def send(sock, text):
    data = json.dumps({"protocol_version": 1, "event_type": "send", "payload": {"text": text}}).encode()
    mask = b"abcd"
    length = bytes([len(data)]) if len(data) < 126 else b"\x7e" + struct.pack("!H", len(data))
    sock.sendall(b"\x81" + bytes([length[0] | 128]) + length[1:] + mask + bytes(value ^ mask[index % 4] for index, value in enumerate(data)))


def receive(sock):
    first, second = exact(sock, 2)
    assert first == 0x81 and not second & 128
    length = second & 127
    if length == 126:
        length = struct.unpack("!H", exact(sock, 2))[0]
    assert length < 8192
    return json.loads(exact(sock, length))


def main():
    with tempfile.TemporaryDirectory(prefix="akamata-chat-wire-") as directory:
        with socket.socket() as reservation:
            reservation.bind(("127.0.0.1", 0))
            port = reservation.getsockname()[1]
        environment = dict(os.environ, PORT=str(port), DATABASE_URL="file:" + directory + "/chat.db")
        with open(Path(directory) / "server.log", "w+") as log:
            server = subprocess.Popen([str(ROOT / "zig-out/bin/chat")], cwd=directory, env=environment, stdout=log, stderr=log)
            clients = []
            try:
                base = f"http://127.0.0.1:{port}"
                deadline = time.monotonic() + 10
                while True:
                    try:
                        with urllib.request.urlopen(base + "/health", timeout=1) as response:
                            assert response.status == 200
                        break
                    except OSError:
                        if server.poll() is not None or time.monotonic() > deadline:
                            log.seek(0)
                            raise RuntimeError(log.read())
                        time.sleep(0.05)
                request = urllib.request.Request(base + "/rooms", data=b'{"name":"wire"}', headers={"content-type": "application/json"})
                with urllib.request.urlopen(request, timeout=5) as response:
                    assert response.status == 201
                    room = json.load(response)["id"]
                alice = connect(port, room, "alice"); clients.append(alice)
                bob = connect(port, room, "bob"); clients.append(bob)
                send(bob, "registered")
                assert receive(bob)["payload"]["user"] == "bob"
                assert receive(alice)["payload"]["text"] == "registered"
                send(alice, "portable frame")
                for client in clients:
                    event = receive(client)
                    assert event["event_type"] == "message" and event["payload"]["text"] == "portable frame"
                with urllib.request.urlopen(base + f"/rooms/{room}/messages", timeout=5) as response:
                    assert len(json.load(response)["messages"]) == 2
                for client in clients:
                    client.close()
                clients.clear()
                start = time.monotonic()
                server.send_signal(signal.SIGTERM)
                assert server.wait(timeout=10) == 0
                print(json.dumps({"example": "chat", "evidence": "Native loopback HTTP + masked WebSocket frames", "clients": 2, "persisted_messages": 2, "shutdown_seconds": round(time.monotonic() - start, 3)}))
            finally:
                for client in clients:
                    client.close()
                if server.poll() is None:
                    server.terminate()
                    try:
                        server.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        server.kill(); server.wait()


if __name__ == "__main__":
    main()
