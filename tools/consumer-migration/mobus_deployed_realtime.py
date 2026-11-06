#!/usr/bin/env python3
"""Acceptance on the existing /dev Workers only. No firmware/admin mutation."""
import importlib.util
import json
import os
import pathlib
import secrets
import tempfile
import subprocess
import time
import urllib.error
import urllib.request
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
BASE = 'https://mobus-backend.mimoc-maker.workers.dev'
os.environ['MOBUS_BASE_URL'] = BASE
spec = importlib.util.spec_from_file_location('acceptance', S / 'mobus-backend/scripts/native_e2e.py')
module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
checks, sockets = [], []


def req(method, path, body=None, token=None, status=200):
    data = json.dumps(body).encode() if body is not None else None
    headers = {'User-Agent': 'Akamata-Release-Verification', 'Content-Type': 'application/json'}
    if token: headers['Authorization'] = 'Bearer ' + token
    try: response = urllib.request.urlopen(urllib.request.Request(BASE + path, data=data, headers=headers, method=method), timeout=30)
    except urllib.error.HTTPError as error: response = error
    with response:
        assert response.status == status, (method, path, response.status)
        raw = response.read()
        return json.loads(raw) if 'json' in response.headers.get('content-type', '') and raw else raw


result = {'status': 'failed', 'scope': 'existing dev Workers; production /api and DB route unchanged', 'checks': checks}
try:
    users = [req('POST', '/api/auth/register', {'login_id': 'akamata-release-' + uuid.uuid4().hex, 'nickname': 'AkTest', 'password': secrets.token_urlsafe(24)}, status=201) for _ in range(3)]
    a, b, outsider = users
    friend = req('POST', '/api/friends/request', {'receiver_id': b['user_id']}, a['token'], 201)
    req('POST', '/api/friends/respond', {'request_id': str(friend['request_id']), 'accept': True}, b['token'])
    aw = module.WebSocket('/realtime/user', a['token']); bw = module.WebSocket('/realtime/user', b['token']); sockets += [aw, bw]
    call = req('POST', '/api/rtchat/call', {'receiver_id': b['user_id']}, a['token'], 201); sid = call['session_id']
    assert module.event_type(bw.recv()) == 'call_offer'
    req('POST', '/api/rtchat/call/respond', {'session_id': sid, 'accept': True}, b['token'])
    assert module.event_type(aw.recv()) == 'call_accept'; aw.close(); bw.close()
    checks.append('user rooms, call offer/accept via named Service Binding and DO')
    try:
        module.WebSocket('/realtime/call:' + sid, outsider['token']); raise RuntimeError('unauthorized room accepted')
    except AssertionError: pass
    ac = module.WebSocket('/realtime/call:' + sid, a['token']); bc = module.WebSocket('/realtime/call:' + sid, b['token']); sockets += [ac, bc]
    for sender, peer in ((ac, bc), (bc, ac)):
        for event, payload in (('morse_signal', {'pressed': True}), ('morse_text', {'text': 'release-test'})):
            sender.send({'protocol_version': 1, 'event_type': event, 'payload': {'session_id': sid, **payload}})
            assert module.event_type(peer.recv()) == event; sender.expect_silent()
    bc.close(); bc = module.WebSocket('/realtime/call:' + sid, b['token']); sockets.append(bc)
    bc.send({'protocol_version': 1, 'event_type': 'morse_text', 'payload': {'session_id': sid, 'text': 'reconnected'}})
    assert module.event_type(ac.recv()) == 'morse_text'; bc.expect_silent()
    checks.append('bidirectional Signal/Text, sender exclusion, reconnect')
    module.BASE = 'https://mimoc.jp'
    proxy = module.WebSocket('/dev/realtime/call:' + sid, a['token']); proxy.close()
    module.BASE = BASE; checks.append('existing /dev WebSocket proxy')
    bc.send({'protocol_version': 1, 'event_type': 'call_end', 'payload': {'session_id': sid}})
    assert module.event_type(ac.recv()) == 'call_end'; assert req('GET', '/api/rtchat/call/status', token=a['token'])['active'] is False
    checks.append('call end and inactive state; outsider denied')
    assert req('GET', '/ehagaki/health')['status'] == 'ok'; checks.append('Ehagaki gateway service binding')
    crash = req('POST', '/api/crash-reports', {'device_id': 'release-test-' + uuid.uuid4().hex, 'reset_reason': 'release-verification'}, a['token'], 201)
    dump = b'akamata-release-test-dump'
    request = urllib.request.Request(BASE + crash['dump_url'], data=dump, method='PUT', headers={'Authorization': 'Bearer ' + a['token'], 'Content-Type': 'application/octet-stream', 'User-Agent': 'Akamata-Release-Verification'})
    with urllib.request.urlopen(request, timeout=30) as response: assert response.status == 201
    with tempfile.TemporaryDirectory() as directory:
        output = pathlib.Path(directory) / 'dump'
        child = subprocess.run(['wrangler', 'r2', 'object', 'get', 'mobus-backend-files/crash/' + str(crash['report_id']) + '.bin', '--remote', '--file', str(output)], capture_output=True, text=True, timeout=60)
        assert child.returncode == 0 and output.read_bytes() == dump
    checks.append('dedicated dev Crash Dump upload and byte-exact R2 readback')
    with urllib.request.urlopen(urllib.request.Request('https://mimoc.jp/dev/api/public/ping', headers={'User-Agent': 'Akamata-Release-Verification'}), timeout=30) as response: assert response.status == 200
    checks.append('existing /dev HTTP proxy')
    result.update(status='success', retained_synthetic_test_accounts=3,
                  firmware_admin_writes='not performed: production firmware must not be overwritten; full isolated staging suite passed')
finally:
    for ws in sockets: ws.close()
    (S / 'mobus-deployed-realtime.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
