#!/usr/bin/env python3
"""Run final real-provider checks sequentially against fixed staging URLs."""
import json
import pathlib
import subprocess
ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
commands = [
    ['node', 'tools/consumer-migration/news_staging.mjs', 'final'],
    ['node', 'tools/consumer-migration/ehagaki_staging.mjs'],
    ['python3', 'tools/consumer-migration/mobus_staging.py'],
    ['node', str(S / 'Yaku/tests/http-smoke.mjs'), 'https://yaku-akamata-migration-20261106.mimoc-maker.workers.dev'],
]
evidence = []
for index, command in enumerate(commands):
    log = S / 'logs' / f'final-live-{index}.log'
    with log.open('w') as stream:
        result = subprocess.run(command, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT, timeout=180)
    evidence.append({'command': command, 'exit': result.returncode, 'log': str(log.relative_to(ROOT))})
    print(index, result.returncode, flush=True)
    (S / 'final-live.json').write_text(json.dumps(evidence, indent=2) + '\n')
    if result.returncode:
        raise SystemExit(result.returncode)
