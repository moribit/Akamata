#!/usr/bin/env python3
"""Serial regression commands, raw logs and exact exit status. No benchmarks."""
import json, subprocess, time
from pathlib import Path
base = Path('benchmark-results/db-optimization/raw')
base.mkdir(parents=True, exist_ok=True)
commands = [['zig', 'build', 'test', 'db-pool-test', '-j2', '--summary', 'all'], ['zig', 'build', 'test', 'db-pool-test', 'documentation-test', '-Doptimize=ReleaseSafe', '-j2', '--summary', 'all'], ['zig', 'build', 'test', '-Doptimize=ReleaseFast', '-j2', '--summary', 'all'], ['zig', 'build', 'portable-application-test', 'documentation-test', '-Dbackend=workers', '-Doptimize=ReleaseSafe', '-j2', '--summary', 'all'], ['zig', 'build', 'transport-contract-test', '-Doptimize=ReleaseSafe', '-j2', '--summary', 'all'], ['zig', 'build', 'db-pool-test', '-Druntime-tsan=true', '-Doptimize=ReleaseSafe', '-j2', '--summary', 'all']]
result = {'source_sha': subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(), 'note': 'working tree core is source delta recorded in final commit', 'runs': []}
for i, command in enumerate(commands):
    log = base / f'validation-{i}.log'
    start = time.monotonic()
    print('START', command, flush=True)
    with log.open('w') as f:
        proc = subprocess.run(command, stdout=f, stderr=subprocess.STDOUT)
    result['runs'].append(dict(command=command, exit=proc.returncode, seconds=time.monotonic() - start, log=str(log)))
    (base / 'validation.json').write_text(json.dumps(result, indent=2) + '\n')
    print('END', proc.returncode, log, flush=True)
    if proc.returncode:
        raise SystemExit(proc.returncode)
