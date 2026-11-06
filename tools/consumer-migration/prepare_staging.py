#!/usr/bin/env python3
"""Create only the explicitly named disposable migration resources (no prod data)."""
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
SCRATCH = ROOT / '.zig-cache/consumer-migration'
STATE = SCRATCH / 'staging-resources.json'
PREFIX = 'akamata-migration-20261106-'


def run(args):
    result = subprocess.run(['rtk', 'proxy', 'wrangler', *args], cwd=SCRATCH,
                            text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout


def main():
    state = json.loads(STATE.read_text()) if STATE.exists() else {'d1': {}, 'r2': {}}
    for app in ('news', 'ehagaki', 'mobus'):
        if app not in state['d1']:
            name = PREFIX + app
            output = run(['d1', 'create', name])
            match = re.search(r'"database_id"\s*:\s*"([0-9a-f-]{36})"', output)
            if not match:
                match = re.search(r'database_id\s*=\s*"([0-9a-f-]{36})"', output)
            if not match:
                raise RuntimeError('Database created; inspect output before retrying: ' + output)
            state['d1'][app] = {'name': name, 'id': match[1]}
            STATE.write_text(json.dumps(state, indent=2) + '\n')
            print('created isolated D1:', name, flush=True)
    for app in ('news', 'mobus'):
        if app not in state['r2']:
            name = PREFIX + app
            run(['r2', 'bucket', 'create', name])
            state['r2'][app] = name
            STATE.write_text(json.dumps(state, indent=2) + '\n')
            print('created isolated R2:', name, flush=True)


if __name__ == '__main__':
    main()
