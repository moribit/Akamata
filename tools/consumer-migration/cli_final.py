#!/usr/bin/env python3
"""Read-only sync checks and fail-closed deploy flag verification."""
import hashlib
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
CLI = ROOT / 'zig-out/bin/akamata'
expected = {'Yaku': 'AkamataDependencyNotFound', 'mimoc_news': 'ManagedFileModified',
            'Ehagaki': None, 'mobus-backend': None}
results = []
for repo, error in expected.items():
    result = subprocess.run([str(CLI), 'sync', '--dry-run'], cwd=S / repo, capture_output=True, text=True)
    output = result.stdout + result.stderr
    assert (result.returncode == 0) == (error is None), output
    if error:
        assert error in output, output
    results.append({'repo': repo, 'exit': result.returncode, 'expected_protection': error})
    (S / 'logs' / (repo + '-final-sync.log')).write_text(output)
result = subprocess.run([str(CLI), 'deploy', '--workers', '--dry-run'], cwd=S, capture_output=True, text=True)
assert result.returncode == 1 and 'no action taken' in result.stderr and 'UsageError' in result.stderr
value = {'candidate': '2714af09fb6c910581a8397c0cb69ebe6a4eccda',
         'cli_sha256': hashlib.sha256(CLI.read_bytes()).hexdigest(), 'sync': results,
         'unsupported_deploy_dry_run': 'rejected before external commands; CLI mock regression verifies zero invocations'}
(S / 'final-cli.json').write_text(json.dumps(value, indent=2) + '\n')
print(json.dumps(value))
