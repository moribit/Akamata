#!/usr/bin/env python3
"""Black-box socket contract, shared by every evaluated Transport adapter.

The kqueue/epoll modes evaluate true multiplexed sockets and shared HTTP;
passing this suite alone does not certify Reactor production safety.
Every read/process wait is bounded; fixtures use OS-selected free ports.
"""
import contextlib
import os
import platform
import signal
import socket
import struct
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

BINARY = str(Path(sys.argv[1]).resolve())


class Client:
    def __init__(self, port):
        self.sock = socket.create_connection(("127.0.0.1", port), timeout=3)
        self.sock.settimeout(3)
        self.pending = b""

    def send(self, data):
        self.sock.sendall(data)

    def response(self):
        while b"\r\n\r\n" not in self.pending:
            chunk = self.sock.recv(65536)
            if not chunk:
                raise AssertionError("EOF before response header")
            self.pending += chunk
        head, self.pending = self.pending.split(b"\r\n\r\n", 1)
        status = int(head.split(b" ")[1])
        headers = dict(line.lower().split(b": ", 1) for line in head.split(b"\r\n")[1:])
        length = int(headers.get(b"content-length", b"0"))
        while len(self.pending) < length:
            chunk = self.sock.recv(65536)
            if not chunk:
                raise AssertionError("truncated response body")
            self.pending += chunk
        body, self.pending = self.pending[:length], self.pending[length:]
        return status, headers, body

    def eof(self):
        try:
            chunk = self.sock.recv(1024)
        except ConnectionResetError:
            return
        if chunk:
            raise AssertionError(f"expected closed socket, received {chunk!r}")

    def collect(self):
        out, self.pending = self.pending, b""
        while True:
            try:
                chunk = self.sock.recv(65536)
            except ConnectionResetError:
                break
            if not chunk:
                break
            out += chunk
        return out

    def close(self):
        self.sock.close()


def request(path="/hello", close=False, extra=b""):
    return (b"GET " + path.encode() + b" HTTP/1.1\r\nHost: localhost\r\n" + extra
            + (b"Connection: close\r\n" if close else b"") + b"\r\n")


UPGRADE = b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"


def masked_frame(opcode, payload, fin=True):
    mask = b"mask"
    length = bytes([0x80 | len(payload)]) if len(payload) < 126 else b"\xfe" + struct.pack("!H", len(payload))
    return bytes([(0x80 if fin else 0) | opcode]) + length + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(payload))


def receive_bytes(client, expected):
    while len(client.pending) < len(expected):
        chunk = client.sock.recv(65536)
        if not chunk:
            raise AssertionError("EOF before frame")
        client.pending += chunk
    if client.pending[:len(expected)] != expected:
        raise AssertionError((client.pending[:len(expected)], expected))
    client.pending = client.pending[len(expected):]


class Contract(unittest.TestCase):
    adapter = "threaded"

    def test_application_execution_capability_is_explicit(self):
        with self.server() as (_, connect):
            for path in ("/sync-stream", "/sync-upgrade"):
                c = connect()
                c.send(request(path, close=True, extra=UPGRADE if "upgrade" in path else b""))
                raw = c.collect()
                if self.adapter in ("kqueue", "epoll"):
                    self.assertTrue(raw.startswith(b"HTTP/1.1 501"), raw)
                    self.assertIn(b"unsupported_application_execution", raw)
                    self.assertEqual(raw.count(b"HTTP/1.1"), 1)
                else:
                    self.assertTrue(raw.startswith(b"HTTP/1.1 " + (b"101" if "upgrade" in path else b"200")), raw)

    def test_fragment_control_utf8_and_invalid_upgrade_cleanup(self):
        with self.server("shutdown") as (_, connect):
            c = connect()
            frames = masked_frame(1, b"\xe2\x82", False) + masked_frame(9, b"p") + masked_frame(0, b"\xac")
            c.send(request("/upgrade-echo", extra=UPGRADE) + frames)
            self.assertEqual(c.response()[0], 101)
            receive_bytes(c, b"\x8a\x01p\x81\x03\xe2\x82\xac")
            c.eof()
            for bad in (masked_frame(1, b"\xff"), b"\x81\x01x", masked_frame(8, b"\x00")):
                c = connect()
                c.send(request("/upgrade-echo", extra=UPGRADE))
                self.assertEqual(c.response()[0], 101)
                c.send(bad)
                c.eof()
                normal = connect()
                normal.send(request(close=True))
                self.assertEqual(normal.response()[0], 200)

    def test_application_isolation_with_active_idle_upgrades_and_slow_streams(self):
        with self.server("stress") as (_, connect):
            idle = [connect() for _ in range(4)]
            for c in idle:
                c.send(request("/upgrade-wait", extra=UPGRADE))
                self.assertEqual(c.response()[0], 101)
            streams = [connect() for _ in range(4)]
            for c in streams:
                c.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
                c.send(request("/large"))
                while b"\r\n\r\n" not in c.pending:
                    c.pending += c.sock.recv(1024)
            active = [connect() for _ in range(2)]
            for c in active:
                c.send(request("/upgrade-room", extra=UPGRADE))
                self.assertEqual(c.response()[0], 101)
                receive_bytes(c, b"\x81\x05ready")
            for i in range(8):
                active[0].send(masked_frame(1, b"fair"))
                for c in active:
                    receive_bytes(c, b"\x81\x04fair")
                normal = connect()
                normal.sock.settimeout(.25)
                started = time.monotonic()
                normal.send(request(close=True))
                self.assertEqual(normal.response()[0], 200)
                self.assertLess(time.monotonic() - started, .25)
                time.sleep(.02)

    @contextlib.contextmanager
    def server(self, profile="normal"):
        with socket.socket() as probe:
            probe.bind(("127.0.0.1", 0))
            port = probe.getsockname()[1]
        with tempfile.TemporaryFile() as log:
            server_profile = "incremental-" + profile if getattr(self, "incremental", False) else profile
            proc = subprocess.Popen([BINARY, self.adapter, str(port), server_profile], stdout=log, stderr=log)
            clients = []

            def connect():
                client = Client(port)
                clients.append(client)
                return client

            try:
                for _ in range(100):
                    if proc.poll() is not None:
                        log.seek(0)
                        raise AssertionError(log.read().decode())
                    try:
                        probe_client = connect()
                        probe_client.send(request(close=True))
                        if profile == "write-zero":
                            probe_client.eof()
                        else:
                            self.assertEqual(probe_client.response()[0], 200)
                        probe_client.eof()
                        probe_client.close()
                        break
                    except (ConnectionRefusedError, TimeoutError):
                        time.sleep(.02)
                else:
                    raise AssertionError("fixture startup deadline")
                yield proc, connect
            finally:
                # Always close clients, including a blocked writer, before a
                # fallback shutdown. The shutdown tests explicitly assert the
                # process exits while their idle clients remain open.
                for client in clients:
                    client.close()
                if proc.poll() is None:
                    proc.send_signal(signal.SIGTERM)
                try:
                    proc.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
                    self.fail("fixture shutdown exceeded contract deadline")
                if proc.returncode != 0:
                    log.seek(0)
                    self.fail(f"fixture exit {proc.returncode}: {log.read().decode()}")
                log.seek(0)
                self.assertNotIn(b"memory address", log.read(), "fixture allocator leak")

    def test_normal_request_and_disconnect(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(request(close=True))
            self.assertEqual(client.response()[::2], (200, b"hello"))
            client.eof()
            abandoned = connect()
            abandoned.send(b"GET /hello HTTP/1.1\r\nHost:")
            abandoned.close()
            normal = connect()
            normal.send(request(close=True))
            self.assertEqual(normal.response()[0], 200)

    def test_malformed_and_transfer_encoding(self):
        cases = [
            (b"GET / HTTP/2.0\r\nHost: a\r\n\r\n", 400),
            (b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 0\r\nContent-Length: 0\r\n\r\n", 400),
            (b"POST /echo HTTP/1.1\r\nHost: a\r\nTransfer-Encoding: gzip, chunked\r\n\r\n", 501),
        ]
        with self.server() as (_, connect):
            for wire, code in cases:
                client = connect()
                client.send(wire)
                self.assertEqual(client.response()[0], code)
                client.eof()

    def test_header_and_body_limits(self):
        with self.server() as (_, connect):
            cases = [
                (request(extra=b"X: " + b"a" * 300 + b"\r\n"), 431),
                (request(extra=b"X: a\r\n" * 9), 431),
                (b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 65\r\n\r\n", 413),
                (b"POST /echo HTTP/1.1\r\nHost: a\r\nTransfer-Encoding: chunked\r\n\r\n1000000\r\n", 413),
            ]
            for wire, code in cases:
                client = connect()
                client.send(wire)
                self.assertEqual(client.response()[0], code)
                client.eof()

    def test_keep_alive_multiple_and_request_limit(self):
        with self.server() as (_, connect):
            client = connect()
            for index in range(3):
                client.send(request())
                status, headers, body = client.response()
                self.assertEqual((status, body), (200, b"hello"))
                if index == 2:
                    self.assertEqual(headers[b"connection"], b"close")
            client.eof()

    def test_pipeline_and_buffer_residue(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(request() * 4)
            for _ in range(3):
                self.assertEqual(client.response()[2], b"hello")
            self.assertEqual(client.pending, b"")
            client.eof()
            client = connect()
            client.send(b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 3\r\n\r\nabc" + request(close=True))
            self.assertEqual(client.response()[2], b"abc")
            self.assertEqual(client.response()[2], b"hello")
            client.eof()

    def test_partial_request_and_partial_next_header(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(request() + b"POST /echo HTTP")
            self.assertEqual(client.response()[2], b"hello")
            time.sleep(.03)
            client.send(b"/1.1\r\nHost: a\r\nContent-Length: 5\r\nConnection: close\r\n\r\nhe")
            time.sleep(.03)
            client.send(b"llo")
            self.assertEqual(client.response()[2], b"hello")
            client.eof()

    def test_chunked_request(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(b"POST /echo HTTP/1.1\r\nHost: a\r\nTransfer-Encoding: chunked\r\nConnection: close\r\n\r\n3\r\nabc\r\n0\r\n\r\n")
            self.assertEqual(client.response()[2], b"abc")
            client.eof()

    def test_idle_timeout(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(request())
            client.response()
            started = time.monotonic()
            client.eof()
            self.assertLess(time.monotonic() - started, 1.5)

    def test_trickle_does_not_reset_header_deadline(self):
        with self.server() as (_, connect):
            client = connect()
            started = time.monotonic()
            for byte in b"GET /hello HTTP/1.1":
                try:
                    client.send(bytes([byte]))
                except (BrokenPipeError, ConnectionResetError):
                    break
                time.sleep(.06)
            client.eof()
            self.assertLess(time.monotonic() - started, .9)

    def test_shutdown_with_partial_request(self):
        with self.server() as (proc, connect):
            client = connect()
            client.send(b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 5\r\n\r\nhe")
            time.sleep(.04)
            proc.send_signal(signal.SIGTERM)
            client.eof()
            proc.wait(timeout=1.5)

    def test_header_body_and_total_timeout(self):
        for profile, wire in [
            ("normal", b"GET /hello HTTP/1.1\r\nHost:"),
            ("normal", b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 5\r\n\r\nhe"),
            ("total", b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 5\r\n\r\nhe"),
        ]:
            with self.server(profile) as (_, connect):
                client = connect()
                started = time.monotonic()
                client.send(wire)
                client.eof()
                elapsed = time.monotonic() - started
                self.assertGreater(elapsed, .1)
                self.assertLess(elapsed, 1.5)

    def test_stream_and_stream_error(self):
        with self.server() as (_, connect):
            for path, expected in [("/stream", b"3\r\none\r\n3\r\ntwo\r\n"), ("/stream-error", b"7\r\npartial\r\n")]:
                client = connect()
                client.send(request(path))
                raw = client.collect()
                self.assertTrue(raw.startswith(b"HTTP/1.1 200"))
                self.assertIn(b"transfer-encoding: chunked", raw)
                self.assertIn(expected, raw)
                self.assertTrue(raw.endswith(b"0\r\n\r\n"))

    def test_upgrade_ownership(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(request("/upgrade", extra=b"Connection: Upgrade\r\nUpgrade: websocket\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"))
            raw = client.collect()
            self.assertTrue(raw.startswith(b"HTTP/1.1 101"))
            self.assertIn(b"s3pPLMBiTxaQ9kYGzzhZRbK+xOo=", raw)
            self.assertIn(b"\x81\x08upgraded", raw)
            self.assertEqual(raw.count(b"HTTP/1.1"), 1)
            normal = connect()
            normal.send(request(close=True))
            self.assertEqual(normal.response()[0], 200)

    def test_fixed_length_stream_and_truncation(self):
        with self.server() as (_, connect):
            client = connect()
            client.send(request("/fixed"))
            self.assertEqual(client.response()[2], b"hello")
            client.eof()
            truncated = connect()
            truncated.send(request("/fixed-short"))
            raw = truncated.collect()
            self.assertIn(b"content-length: 5", raw)
            self.assertTrue(raw.endswith(b"\r\n\r\nhe"), repr(raw))
            self.assertEqual(raw.count(b"HTTP/1.1"), 1)

    def test_peer_and_trusted_proxy(self):
        for profile, expected in [("normal", b"127.0.0.1"), ("proxy", b"203.0.113.7"), ("untrusted", b"127.0.0.1")]:
            with self.server(profile) as (_, connect):
                client = connect()
                client.send(request("/ip", close=True, extra=b"X-Forwarded-For: 203.0.113.7\r\n"))
                self.assertEqual(client.response()[2], expected)

    def test_upgrade_preserves_coalesced_frame(self):
        with self.server() as (_, connect):
            client = connect()
            header = request("/upgrade-echo", extra=b"Connection: Upgrade\r\nUpgrade: websocket\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n")
            mask = b"abcd"
            payload = b"hello"
            frame = b"\x81\x85" + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
            client.send(header + frame)
            raw = client.collect()
            self.assertTrue(raw.startswith(b"HTTP/1.1 101"))
            self.assertIn(b"\x81\x05hello", raw)
            self.assertEqual(raw.count(b"HTTP/1.1"), 1)

    def test_max_connections_overload_and_recovery(self):
        with self.server("overload") as (_, connect):
            first, second = connect(), connect()
            # A completed response is the admission barrier for each occupied
            # slot; avoid guessing whether an accept thread ran after connect.
            for occupied in (first, second):
                occupied.send(request())
                self.assertEqual(occupied.response()[0], 200)
            excess = connect()
            excess.eof()
            first.close()
            time.sleep(.08)
            normal = connect()
            normal.send(request(close=True))
            self.assertEqual(normal.response()[0], 200)

    def test_backpressure_does_not_starve_other_connections(self):
        with self.server() as (_, connect):
            blocked = connect()
            blocked.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
            blocked.send(request("/large"))
            # Stop consuming a 16 MiB response. The connection worker can
            # block in the standard writer; it must not spin/starve acceptors.
            time.sleep(.08)
            normal = connect()
            normal.send(request(close=True))
            self.assertEqual(normal.response()[2], b"hello")
            # Reset mid-write must release its connection slot and allocations.
            blocked.sock.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0))
            blocked.close()

    def test_graceful_shutdown_and_idle_connections(self):
        with self.server("shutdown") as (proc, connect):
            never_sent = connect()
            keep_alive = connect()
            keep_alive.send(request())
            keep_alive.response()
            started = time.monotonic()
            proc.send_signal(signal.SIGTERM)
            proc.wait(timeout=1.5)
            self.assertLess(time.monotonic() - started, 1.5)
            never_sent.eof()
            keep_alive.eof()

    def test_shutdown_drains_inflight_response(self):
        with self.server("shutdown") as (proc, connect):
            client = connect()
            client.send(request("/slow", close=True))
            # Header flush is the handler-start barrier, not a timing guess.
            while b"\r\n\r\n" not in client.pending:
                client.pending += client.sock.recv(4096)
            proc.send_signal(signal.SIGTERM)
            raw = client.collect()
            self.assertIn(b"completed", raw)
            proc.wait(timeout=1.5)

    def test_absolute_write_deadline_slow_reader(self):
        with self.server("write-slot") as (_, connect):
            client = connect()
            client.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
            client.send(request("/large"))
            started = time.monotonic()
            # Tiny progress must not extend the response budget.
            for _ in range(7):
                self.assertTrue(client.sock.recv(4096))
                time.sleep(.06)
            # A single admission slot must be reclaimed while the original
            # client still has unread bytes. TCP FIN follows kernel-buffered
            # output: draining a tiny receive window is not a close deadline.
            normal = connect()
            normal.send(request(close=True))
            self.assertEqual(normal.response()[0], 200)
            self.assertLess(time.monotonic() - started, 2)
            client.close()

    def test_stream_write_deadline_while_producer_pauses(self):
        with self.server("write") as (_, connect):
            client = connect()
            client.send(request("/paused-stream"))
            started = time.monotonic()
            raw = client.collect()
            self.assertLess(time.monotonic() - started, .8)
            self.assertNotIn(b"completed", raw)
            self.assertTrue(raw.startswith(b"HTTP/1.1 200"))

    def test_zero_write_budget_permits_no_socket_output(self):
        with self.server("write-zero") as (_, connect):
            for path in ("/hello", "/stream", "/upgrade"):
                client = connect()
                extra = b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n" if path == "/upgrade" else b""
                client.send(request(path, close=True, extra=extra))
                client.eof()

    def test_upgrade_hub_snapshot_disconnect_ownership(self):
        with self.server("shutdown") as (_, connect):
            extra = b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
            payload = b"borrowed-transport"
            mask = b"mask"
            frame = bytes([0x81, 0x80 | len(payload)]) + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
            expected = bytes([0x81, len(payload)]) + payload
            def receive(client, expected=expected):
                while len(client.pending) < len(expected):
                    data = client.sock.recv(4096)
                    self.assertTrue(data)
                    client.pending += data
                self.assertEqual(client.pending[:len(expected)], expected)
                client.pending = client.pending[len(expected):]
            for _ in range(8):
                peers = [connect() for _ in range(3)]
                for peer in peers:
                    peer.send(request("/upgrade-room", extra=extra))
                    self.assertEqual(peer.response()[0], 101)
                    receive(peer, b"\x81\x05ready")
                peers[0].send(frame)
                receive(peers[0])
                peers[1].sock.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0))
                peers[1].close()
                receive(peers[2])
                peers[0].send(frame)
                receive(peers[0]); receive(peers[2])
                peers[0].close(); peers[2].close()
                time.sleep(.02)

    def test_forced_drain_slow_writer_and_repeated_signal(self):
        with self.server("drain") as (proc, connect):
            client = connect()
            client.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
            client.send(request("/large"))
            self.assertTrue(client.sock.recv(1))
            started = time.monotonic()
            proc.send_signal(signal.SIGTERM)
            proc.send_signal(signal.SIGINT)
            proc.wait(timeout=1.5)
            self.assertLess(time.monotonic() - started, 1.5)
            # Process exit proves owners drained. Do not time receipt of bytes
            # already handed to the kernel before forced socket shutdown.
            client.close()

    def test_forced_drain_partial_request(self):
        with self.server("drain") as (proc, connect):
            client = connect()
            client.send(b"POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 5\r\n\r\nhe")
            time.sleep(.04)
            proc.send_signal(signal.SIGTERM)
            client.eof()
            proc.wait(timeout=1.5)

    def test_forced_drain_upgraded_connection(self):
        with self.server("drain") as (proc, connect):
            client = connect()
            client.send(request("/upgrade-wait", extra=b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"))
            self.assertEqual(client.response()[0], 101)
            proc.send_signal(signal.SIGTERM)
            client.eof()
            proc.wait(timeout=1.5)

    def test_upgraded_writer_forced_drain_and_disconnect(self):
        with self.server("drain") as (proc, connect):
            client = connect()
            client.sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)
            client.send(request("/upgrade-large", extra=b"Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"))
            self.assertEqual(client.response()[0], 101)
            proc.send_signal(signal.SIGTERM)
            client.sock.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0))
            client.close()
            proc.wait(timeout=1.5)

    def test_handler_and_stream_outlive_grace_without_preemption(self):
        with self.server("drain") as (proc, connect):
            client = connect()
            client.send(request("/slow", close=True))
            while b"\r\n\r\n" not in client.pending:
                client.pending += client.sock.recv(4096)
            proc.send_signal(signal.SIGTERM)
            raw = client.collect()
            # Headers were committed, but expired drain must not send body or
            # a second HTTP response. Handler ownership still must be joined.
            self.assertNotIn(b"completed", raw)
            self.assertEqual(raw.count(b"HTTP/1.1"), 1)
            proc.wait(timeout=1.5)


if __name__ == "__main__":
    gate = subprocess.run([BINARY, "disabled", "0", "normal"], capture_output=True, timeout=5)
    if gate.returncode:
        raise AssertionError("reactor fail-closed gate: " + gate.stderr.decode())
    adapters = ["threaded"]
    if platform.system() == "Darwin":
        adapters.append("kqueue")
    elif platform.system() == "Linux":
        adapters.append("epoll")
    if "--group" in sys.argv[2:]:
        adapters.append("group")
    if "--only-group" in sys.argv[2:]:
        adapters = ["group"]
    suite = unittest.TestSuite()
    for adapter in adapters:
        kind = type("Contract_" + adapter, (Contract,), {"adapter": adapter})
        suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(kind))
    if "--only-group" not in sys.argv[2:]:
        kind = type("Contract_threaded_incremental", (Contract,), {"adapter": "threaded", "incremental": True})
        suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(kind))
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    sys.exit(0 if result.wasSuccessful() else 1)
