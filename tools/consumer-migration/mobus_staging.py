#!/usr/bin/env python3
"""Execute Consumer acceptance tests against only the fixed isolated Worker."""
import json
import os
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
values = json.loads((S / 'staging-test-credentials.json').read_text())
env = dict(os.environ, MOBUS_BASE_URL='https://akamata-migration-20261106-mobus.mimoc-maker.workers.dev',
           ADMIN_SECRET=values['ADMIN_SECRET'])
log = S / 'logs/mobus-staging-e2e.log'
with log.open('w') as f:
    result = subprocess.run(['python3', 'scripts/native_e2e.py'], cwd=S / 'mobus-backend',
                            env=env, stdout=f, stderr=subprocess.STDOUT, timeout=180)
evidence = {'status': 'success' if result.returncode == 0 else 'failed', 'exit': result.returncode,
            'target': env['MOBUS_BASE_URL'], 'log': str(log.relative_to(ROOT))}
(S / 'mobus-live.json').write_text(json.dumps(evidence, indent=2) + '\n')
print(json.dumps(evidence))
raise SystemExit(result.returncode)
