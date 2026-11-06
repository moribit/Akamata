#!/usr/bin/env python3
"""Pin reviewed isolated Consumers to the published immutable archive."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
URL = 'https://github.com/moribit/Akamata/archive/refs/tags/v0.2.1.tar.gz'
HASH = 'akamata-0.2.1-uJIoI3crPQE12CxtQ0Iv_d0wHvo0M3USWct-sZKaIc1_'
results = []
for repo in ('Yaku', 'mimoc_news', 'Ehagaki', 'mobus-backend'):
    path = S / repo / 'build.zig.zon'
    old = path.read_text()
    pattern = r'(\.akamata\s*=\s*\.\{\s*\.url\s*=\s*")[^"]+("\s*,\s*\.hash\s*=\s*")[^"]+("\s*,)'
    new, count = re.subn(pattern, lambda m: m[1] + URL + m[2] + HASH + m[3], old)
    assert count == 1, repo
    path.write_text(new)
    results.append({'repo': repo, 'url': URL, 'hash': HASH})
print(json.dumps(results))
(S / 'release-pins.json').write_text(json.dumps(results, indent=2) + '\n')
