#!/usr/bin/env python3
"""Approved code-only rollout. Never provisions, migrates or sets secrets."""
import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import tomllib

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
ORDER = ['Yaku', 'mimoc_news', 'Ehagaki', 'mobus-backend']
TARGETS = {
    'Yaku': [('yaku-mvp', 'deploy/wrangler.toml', 'yaku-mvp_worker.wasm')],
    'mimoc_news': [('mimoc-news', 'deploy/wrangler.jsonc', 'mimoc_news_worker.wasm')],
    'Ehagaki': [('ehagaki', 'deploy/wrangler.toml', 'ehagaki_worker.wasm')],
    'mobus-backend': [('mobus-realtime-handler', 'deploy/wrangler.realtime-handler.toml', 'mobus-backend_worker.wasm'),
                      ('mobus-backend', 'deploy/wrangler.toml', 'mobus-backend_worker.wasm')],
}
parser = argparse.ArgumentParser()
parser.add_argument('repo', choices=ORDER)
parser.add_argument('--deploy', action='store_true')
args = parser.parse_args()
builds = json.loads((S / 'published.json').read_text())['runs']
assert len(builds) == 12 and all(row['exit'] == 0 for row in builds)
assert all('--fork' not in ' '.join(row['command']) for row in builds)
schema = {row['repo']: row for row in json.loads((S / 'production-schema-preflight.json').read_text())}
if args.repo in schema:
    assert schema[args.repo]['status'] == 'validated'
before = {row['worker']: row for row in json.loads((S / 'production-before.json').read_text())}
verification_path = S / 'production-verifications.json'
verified = json.loads(verification_path.read_text()) if verification_path.exists() else {}
if args.deploy:
    assert all(verified.get(repo, {}).get('status') == 'success' for repo in ORDER[:ORDER.index(args.repo)]), 'previous product must pass live verification'
results_path = S / 'production-rollout.json'
results = json.loads(results_path.read_text()) if results_path.exists() else []
cwd = S / args.repo
for worker, config_name, wasm_name in TARGETS[args.repo]:
    config_path = cwd / config_name
    config = tomllib.loads(config_path.read_text()) if config_name.endswith('.toml') else json.loads(config_path.read_text())
    assert config['name'] == worker and not worker.startswith('akamata-migration-')
    assert all(not value.get('database_name', '').startswith('akamata-migration-') for value in config.get('d1_databases', []))
    assert all(not value['bucket_name'].startswith('akamata-migration-') for value in config.get('r2_buckets', []))
    assert all(not value['service'].startswith('akamata-migration-') for value in config.get('services', []))
    if args.repo == 'Ehagaki': assert config['vars']['EHAGAKI_AUTO_MIGRATE'] == 'false'
    if args.repo == 'mimoc_news': assert config['vars']['MIMOC_NEWS_AUTO_MIGRATE'] == 'false'
    zon = (cwd / 'build.zig.zon').read_text()
    assert 'archive/refs/tags/v0.2.1.tar.gz' in zon and 'akamata-0.2.1-uJIoI3crPQE12CxtQ0Iv_d0wHvo0M3USWct-sZKaIc1_' in zon
    if args.deploy:
        inventory = subprocess.run(['wrangler', 'deployments', 'list', '--json', '--config', config_name], cwd=cwd, capture_output=True, text=True, check=True)
        latest = max(json.loads(inventory.stdout), key=lambda row: row['created_on'])
        assert latest['id'] == before[worker]['deployment'], 'deployment changed since recorded rollback; stop and review'
    command = ['wrangler', 'deploy', '--config', config_name, '--keep-vars']
    command += ['--message', 'Approved Akamata v0.2.1 code-only rollout'] if args.deploy else ['--dry-run']
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, timeout=180)
    log = S / 'logs' / (worker + ('-production-deploy.log' if args.deploy else '-production-dry-run.log'))
    log.write_text(result.stdout + result.stderr)
    assert result.returncode == 0, str(log)
    match = re.search(r'Current Version ID: ([0-9a-f-]+)', result.stdout)
    wasm = cwd / 'zig-out/bin' / wasm_name
    row = {'repo': args.repo, 'worker': worker, 'action': 'deploy' if args.deploy else 'dry_run',
           'version': match[1] if match else None, 'app_sha': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=cwd, text=True).strip(),
           'wasm_sha256': hashlib.sha256(wasm.read_bytes()).hexdigest(), 'rollback': before[worker]['versions'],
           'scope': 'existing /dev Workers; production /api unchanged' if args.repo == 'mobus-backend' else 'existing production Worker'}
    results.append(row)
    results_path.write_text(json.dumps(results, indent=2) + '\n')
    print(json.dumps(row), flush=True)
