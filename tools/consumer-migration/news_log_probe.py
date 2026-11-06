#!/usr/bin/env python3
"""Capture only structured app log messages from a public staging GET."""
import json
import pathlib
import signal
import subprocess
import tempfile
import time
import urllib.request
import sys
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
production = '--production' in sys.argv[1:]
probe = uuid.uuid4().hex
config = 'deploy/wrangler.jsonc' if production else 'deploy/wrangler.migration-staging.json'
url = 'https://mimoc-news.mimoc-maker.workers.dev/api/news' if production else 'https://akamata-migration-20261106-news.mimoc-maker.workers.dev/api/news'
with tempfile.TemporaryFile(mode='w+') as stream:
    child = subprocess.Popen(['rtk', 'proxy', 'wrangler', 'tail', '--config',
                              config, '--format=json', '--header', 'X-Akamata-Release-Probe:' + probe],
                             cwd=S / 'mimoc_news', stdout=stream, stderr=subprocess.DEVNULL)
    try:
        time.sleep(8)
        with urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'Akamata-Release-Verification', 'X-Akamata-Release-Probe': probe})) as r:
            request_id = r.headers.get('x-request-id')
            r.read()
        time.sleep(5)
    finally:
        child.send_signal(signal.SIGINT)
        try:
            child.wait(timeout=5)
        except subprocess.TimeoutExpired:
            child.kill(); child.wait()
    stream.seek(0)
    raw = stream.read()
messages = []
decoder = json.JSONDecoder()
while raw:
    start = raw.find('{')
    if start < 0:
        break
    try:
        event, length = decoder.raw_decode(raw[start:])
    except json.JSONDecodeError:
        raw = raw[start + 1:]; continue
    raw = raw[start + length:]
    for log in event.get('logs', []):
        for message in log.get('message', []):
            if isinstance(message, str) and request_id and request_id in message:
                messages.append(message)
result = {'request_id_correlated': bool(messages), 'structured_messages': messages}
(S / ('news-production-log.json' if production else 'news-log-evidence.json')).write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
if not messages:
    raise SystemExit(1)
