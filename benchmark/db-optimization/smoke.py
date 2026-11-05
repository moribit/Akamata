#!/usr/bin/env python3
"""Check six independent paths return the same complete row; no speed thresholds."""
import json, os, re, subprocess, sys
for case in range(6):
    p = subprocess.run([sys.argv[1]], env=dict(os.environ, DB_CASE=str(case), DB_THREADS='2', DB_OPS='500', DB_SQL_LENGTH='0'), check=True, capture_output=True, text=True)
    text = next((x[9:] for x in p.stderr.splitlines() if x.startswith('DB_MICRO ')))
    text = re.sub('("stage_(?:ns|calls)":)\\{([^}]*)\\}', '\\1[\\2]', text)
    row = json.loads(text)
    assert row['errors'] == 0 and row['operations'] == 1000, row
    assert row['checksum'] == 2 * (500 + 100) * 534, row
    assert 0 <= row['p50_ns'] <= row['p95_ns'] <= row['p99_ns'], row
print('DB microfixture: 6 paths preserve row data, error handling and latency ordering')
