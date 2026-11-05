#!/usr/bin/env python3
"""Direct C control only: length excludes NUL vs includes NUL vs -1.
Same executable/SQL/row/gate, all modes have valid sentinel-backed input.
"""
import argparse, json, os, random, re, subprocess, hashlib, platform, time
from pathlib import Path
p = argparse.ArgumentParser()
p.add_argument('binary')
p.add_argument('--output', required=True)
a = p.parse_args()
result = {'binary': str(Path(a.binary).resolve()), 'sha256': hashlib.sha256(Path(a.binary).read_bytes()).hexdigest(), 'os': platform.platform(), 'command': __import__('sys').argv, 'source_sha': subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(), 'runs': []}
for r in range(1, 4):
    for threads in [1, 8, 32, 128]:
        modes = [0, 1, 2]
        random.Random(400 + r + threads).shuffle(modes)
        for mode in modes:
            env = dict(os.environ, DB_CASE='0', DB_THREADS=str(threads), DB_OPS=str(max(1000, 200000 // threads)), DB_SQL_LENGTH=str(mode))
            proc = subprocess.run([a.binary], env=env, check=True, capture_output=True, text=True)
            line = next((x[9:] for x in proc.stderr.splitlines() if x.startswith('DB_MICRO ')))
            line = re.sub('("stage_(?:ns|calls)":)\\{([^}]*)\\}', '\\1[\\2]', line)
            row = json.loads(line)
            row.update(round=r, sql_length_mode=mode)
            assert row['errors'] == 0 and row['checksum'] == (row['operations'] + 100 * threads) * 534, row
            result['runs'].append(row)
            out = Path(a.output)
            tmp = out.with_suffix('.tmp')
            tmp.write_text(json.dumps(result, indent=2) + '\n')
            tmp.replace(out)
            print(r, threads, mode, round(row['operations'] * 1000000000.0 / row['elapsed_ns']), flush=True)
