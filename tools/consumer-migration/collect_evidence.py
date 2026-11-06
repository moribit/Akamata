#!/usr/bin/env python3
"""Publish a small allowlisted evidence snapshot, excluding credentials and raw API rows."""
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
OUT = ROOT / 'docs/consumer-migration/evidence'
OUT.mkdir(exist_ok=True)
candidate = '2714af09fb6c910581a8397c0cb69ebe6a4eccda'


def api(path):
    return json.loads(subprocess.check_output(['gh', 'api', path], text=True, timeout=45))


def main():
    selected = api(f'repos/moribit/Akamata/actions/runs?head_sha={candidate}&per_page=10')['workflow_runs']
    runs = []
    for run in selected:
        jobs = api(f"repos/moribit/Akamata/actions/runs/{run['id']}/jobs?per_page=100")['jobs']
        runs.append({k: run[k] for k in ('id', 'name', 'head_sha', 'status', 'conclusion', 'html_url')})
        runs[-1]['jobs'] = [{k: job[k] for k in ('name', 'status', 'conclusion')} for job in jobs]
    (OUT / 'candidate-ci.json').write_text(json.dumps({'candidate': candidate, 'runs': runs}, indent=2) + '\n')
    for filename in ('news-baseline.json', 'news-candidate.json', 'news-final.json', 'news-log-evidence.json',
                     'ehagaki-live.json', 'mobus-live.json', 'final-live.json',
                     'final-staging-deployments.json', 'final-staging-dry-runs.json',
                     'baseline-mobus-e2e-isolation.json', 'candidate-mobus-e2e-isolation.json',
                     'final-cli.json', 'candidate.json', 'original-checkouts-after.json', 'staging-resources.json'):
        value = json.loads((S / filename).read_text())
        # Replace absolute local command paths, not arbitrary secret-bearing files.
        text = json.dumps(value, indent=2).replace(str(ROOT), '<checkout>')
        (OUT / filename).write_text(text + '\n')
    lines = (S / 'storage-header-before-fix.log').read_text().splitlines()
    excerpt = '\n'.join(lines[:10]).replace(str(ROOT), '<checkout>')
    (OUT / 'storage-header-before-fix.txt').write_text('Controlled old-two-line implementation with the new poison-on-close regression test:\n' + excerpt + '\n')
    print(json.dumps([{'run': r['id'], 'status': r['status'], 'conclusion': r['conclusion'], 'jobs': len(r['jobs'])} for r in runs]))


if __name__ == '__main__':
    main()
