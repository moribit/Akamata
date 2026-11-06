#!/usr/bin/env python3
"""Bounded real HTTP checks; responses are summarized without user records."""
import argparse
import json
import pathlib
import subprocess
import urllib.request
import urllib.error

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
TARGETS = {'mimoc_news': ('https://mimoc-news.mimoc-maker.workers.dev', [('/api/news', 200), ('/admin', 401)]),
           'Ehagaki': ('https://ehagaki.mimoc-maker.workers.dev', [('/health', 200), ('/api/timeline', 200)]),
           'mobus-backend': ('https://mobus-backend.mimoc-maker.workers.dev', [('/api/public/ping', 200), ('/api/ping', 401), ('/ehagaki/health', 200)])}
parser = argparse.ArgumentParser(); parser.add_argument('repo', choices=['Yaku', *TARGETS]); args = parser.parse_args()
evidence = {'status': 'success', 'checks': []}
if args.repo == 'Yaku':
    log = S / 'logs/Yaku-production-smoke.log'
    with log.open('w') as stream:
        result = subprocess.run(['node', str(S / 'Yaku/tests/http-smoke.mjs'), 'https://yaku-mvp.mimoc-maker.workers.dev'], stdout=stream, stderr=subprocess.STDOUT, timeout=120)
    assert result.returncode == 0, str(log)
    evidence['checks'].append('HTTP smoke catalog/quiz/privacy/grading/body limit/OpenAPI/client/static pages')
else:
    base, paths = TARGETS[args.repo]
    for path, expected in paths:
        request = urllib.request.Request(base + path, headers={'User-Agent': 'Akamata-Release-Verification'})
        try:
            response = urllib.request.urlopen(request, timeout=30)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            assert response.status == expected, (path, response.status)
            body = response.read(2 * 1024 * 1024)
            value = json.loads(body) if 'json' in response.headers.get('content-type', '') else None
            evidence['checks'].append({'path': path, 'status': response.status,
                                       'content_type': response.headers.get('content-type'),
                                       'json_keys': sorted(value) if isinstance(value, dict) else None,
                                       'request_id': bool(response.headers.get('x-request-id')),
                                       'server_timing': response.headers.get('server-timing')})
path = S / 'production-verifications.json'
all_results = json.loads(path.read_text()) if path.exists() else {}
all_results[args.repo] = evidence
path.write_text(json.dumps(all_results, indent=2) + '\n')
print(json.dumps({args.repo: evidence}))
