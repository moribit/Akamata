#!/usr/bin/env python3
"""Review/apply managed sync only; custom news glue is deliberately untouched."""
import argparse
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
parser = argparse.ArgumentParser()
parser.add_argument('--apply', action='store_true')
args = parser.parse_args()
rows = []
for repo in ('Yaku', 'Ehagaki', 'mobus-backend'):
    command = [str(ROOT / 'zig-out/bin/akamata'), 'sync']
    if not args.apply:
        command.append('--dry-run')
    result = subprocess.run(command, cwd=S / repo, capture_output=True, text=True)
    log = S / 'logs' / (repo + ('-release-sync-applied.log' if args.apply else '-release-sync-review.log'))
    log.write_text(result.stdout + result.stderr)
    print(repo, result.returncode, flush=True)
    rows.append({'repo': repo, 'exit': result.returncode, 'log': str(log.relative_to(ROOT))})
    if result.returncode:
        raise SystemExit(result.returncode)
(S / ('release-sync-applied.json' if args.apply else 'release-sync-review.json')).write_text(json.dumps(rows, indent=2) + '\n')
