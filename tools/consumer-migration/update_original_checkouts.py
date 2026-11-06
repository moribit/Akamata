#!/usr/bin/env python3
"""Fast-forward original main only if its recorded tracked state is unchanged."""
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
before = json.loads((S / 'original-checkouts-after.json').read_text())
rows = []
for repo in ('Yaku', 'mimoc_news', 'Ehagaki', 'mobus-backend'):
    cwd = pathlib.Path('/Users/mimoc') / repo
    def git(*args):
        return subprocess.check_output(['git', *args], cwd=cwd, text=True).strip()
    assert git('branch', '--show-current') == 'main', 'preserve user branch'
    assert git('rev-parse', 'HEAD') == before[repo]['sha'], 'preserve new user commits'
    subprocess.run(['git', 'diff', '--quiet'], cwd=cwd, check=True)
    subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=cwd, check=True)
    subprocess.run(['git', 'fetch', 'origin', 'main'], cwd=cwd, check=True)
    subprocess.run(['git', 'merge', '--ff-only', 'origin/main'], cwd=cwd, check=True)
    rows.append({'repo': repo, 'before': before[repo]['sha'], 'after': git('rev-parse', 'HEAD'),
                 'remaining_status': git('status', '--short').splitlines()})
    print(repo, rows[-1]['after'], flush=True)
    (S / 'original-checkouts-updated.json').write_text(json.dumps(rows, indent=2) + '\n')
