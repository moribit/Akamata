#!/usr/bin/env python3
"""macOS wall-stack diagnostic of an owned DB process, never a CPU profile."""
import json, os, subprocess, sys, time
from pathlib import Path
binary = sys.argv[1]
base = Path(sys.argv[2])
base.mkdir(parents=True, exist_ok=True)
command = [binary]
env = dict(os.environ, DB_CASE='3', DB_THREADS='32', DB_OPS='100000', DB_SQL_LENGTH='0')
with (base / 'sample-process.log').open('w') as log:
    process = subprocess.Popen(command, env=env, stdout=log, stderr=log)
    try:
        sample = ['sample', str(process.pid), '2', '1', '-file', str(base / 'db-wall-stacks.txt')]
        probe = subprocess.run(sample, capture_output=True, text=True)
        (base / 'sample-command.json').write_text(json.dumps({'command': command, 'environment_overrides': {k: env[k] for k in ['DB_CASE', 'DB_THREADS', 'DB_OPS']}, 'sample_command': sample, 'returncode': probe.returncode, 'stdout': probe.stdout, 'stderr': probe.stderr}, indent=2) + '\n')
        status = process.wait(timeout=60)
        if status:
            raise RuntimeError(f'benchmark exit {status}')
        if probe.returncode:
            raise RuntimeError(f'sample exit {probe.returncode}: {probe.stderr}')
    finally:
        if process.poll() is None:
            process.kill()
        process.wait()
