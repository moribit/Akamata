#!/usr/bin/env python3
"""Read-only schema and rollback references. No resource/secret mutations."""
import hashlib
import json
import pathlib
import subprocess
import argparse

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
TARGETS = {
    'mimoc_news': ('mimoc-news', 'deploy/wrangler.jsonc', {'news': ['title_image_url', 'main_image_url', 'is_pinned']}),
    'Ehagaki': ('ehagaki', 'deploy/wrangler.toml', {'posts': ['user_id', 'bitmap_b64', 'is_public', 'title']}),
    'mobus-backend': ('mobus-backend-dev', 'deploy/wrangler.toml', {
        'users': ['public_id'], 'firmware': ['status', 'uploaded_at', 'published_at'],
        'crash_reports': ['dump_content_type'], 'auth_device_credentials': ['secret_hash'],
        'calls': ['status'], 'messages': ['content'], 'friendships': ['status'], 'devices': ['device_id']}),
}
parser = argparse.ArgumentParser(); parser.add_argument('--after', action='store_true'); args = parser.parse_args()
snapshot = json.loads((S / 'deployments.json').read_text())
rollback = []
for row in snapshot:
    deployments = row.get('deployments', [])
    if isinstance(deployments, dict):
        deployments = deployments.get('deployments', [])
    latest = max(deployments, key=lambda x: x['created_on'])
    rollback.append({'repo': row['repo'], 'worker': row['worker'],
                     'deployment': latest['id'], 'versions': latest['versions'],
                     'created_on': latest['created_on'], 'secret_names': row.get('secret_names', [])})
(S / ('production-after.json' if args.after else 'production-before.json')).write_text(json.dumps(rollback, indent=2) + '\n')
results = []
for repo, (database, config, expected) in TARGETS.items():
    command = ['wrangler', 'd1', 'execute', database, '--remote', '--config', config,
               '--command', "SELECT name,sql FROM sqlite_master WHERE type='table'", '--json']
    result = subprocess.run(command, cwd=S / repo, capture_output=True, text=True, timeout=90)
    item = {'repo': repo, 'database': database, 'exit': result.returncode}
    if result.returncode == 0:
        data = json.loads(result.stdout)
        tables = {x['name']: x['sql'] or '' for batch in data for x in batch.get('results', [])}
        item['missing'] = [table + '.' + column for table, columns in expected.items()
                           for column in columns if table not in tables or column.lower() not in tables[table].lower()]
        item['schema_sha256'] = hashlib.sha256(json.dumps(tables, sort_keys=True).encode()).hexdigest()
        item['tables'] = sorted(expected.keys() & tables.keys())
        item['status'] = 'validated' if not item['missing'] else 'blocked_missing_schema'
    else:
        item['status'] = 'unverified'
    results.append(item)
    print(json.dumps(item), flush=True)
    (S / ('production-schema-after.json' if args.after else 'production-schema-preflight.json')).write_text(json.dumps(results, indent=2) + '\n')
