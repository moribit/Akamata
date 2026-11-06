#!/usr/bin/env python3
"""Validate/deploy fixed isolated targets; refuses any production resource wiring."""
import argparse
import hashlib
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
PREFIX = 'akamata-migration-20261106-'
TARGETS = (
    ('mimoc_news', 'news', 'wrangler.migration-staging.json', 'mimoc_news_worker.wasm'),
    ('Ehagaki', 'ehagaki', 'wrangler.migration-staging.json', 'ehagaki_worker.wasm'),
    ('mobus-backend', 'rt', 'wrangler.migration-handler.json', 'mobus-backend_worker.wasm'),
    ('mobus-backend', 'mobus', 'wrangler.migration-staging.json', 'mobus-backend_worker.wasm'),
)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--deploy-staging', action='store_true')
    args = parser.parse_args()
    resources = json.loads((S / 'staging-resources.json').read_text())
    allowed_ids = {value['id'] for value in resources['d1'].values()}
    allowed_buckets = set(resources['r2'].values())
    evidence = []
    for repo, app, filename, wasm_name in TARGETS:
        cwd = S / repo
        config = json.loads((cwd / 'deploy' / filename).read_text())
        assert config['name'] == PREFIX + app
        assert all(value['database_id'] in allowed_ids for value in config.get('d1_databases', []))
        assert all(value['bucket_name'] in allowed_buckets for value in config.get('r2_buckets', []))
        assert all(value['service'].startswith(PREFIX) for value in config.get('services', []))
        assert not config.get('routes') and not config.get('route')
        secret_app = 'mobus' if app == 'rt' else app
        command = ['rtk', 'proxy', 'wrangler', 'deploy', '--config', 'deploy/' + filename]
        if args.deploy_staging:
            command += ['--secrets-file', '../' + secret_app + '-test-secrets.json',
                        '--message', 'Final isolated Akamata release candidate validation']
        else:
            command += ['--dry-run']
        result = subprocess.run(command, cwd=cwd, capture_output=True, text=True)
        log = S / 'logs' / (app + ('-final-deploy.log' if args.deploy_staging else '-final-dry-run.log'))
        log.write_text(result.stdout + result.stderr)
        version = re.search(r'Current Version ID: ([0-9a-f-]+)', result.stdout)
        wasm = cwd / 'zig-out/bin' / wasm_name
        item = dict(repo=repo, worker=config['name'], exit=result.returncode,
                    version=version[1] if version else None,
                    app_sha=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=cwd, text=True).strip(),
                    wasm_sha256=hashlib.sha256(wasm.read_bytes()).hexdigest())
        evidence.append(item)
        print(json.dumps(item), flush=True)
        if result.returncode:
            raise RuntimeError('staging artifact validation failed: ' + str(log))
    (S / ('final-staging-deployments.json' if args.deploy_staging else 'final-staging-dry-runs.json')).write_text(json.dumps(evidence, indent=2) + '\n')


if __name__ == '__main__':
    main()
