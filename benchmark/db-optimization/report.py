#!/usr/bin/env python3
"""Offline summaries. Refuse missing/duplicate completed cases; retain raw evidence."""
import csv, itertools, json, statistics, sys
from pathlib import Path
root = Path(__file__).resolve().parents[2]
base = root / 'benchmark-results/db-optimization'
sys.path.insert(0, str(root / 'benchmark/competitive/scripts'))
from compare_matrix import metrics

def validate_micro(data, paired=False):
    expected = {(r, c, t, v) for r in range(1, 4) for c in 'ABCDEF' for t in [1, 8, 32, 128] for v in ('AB' if paired else 'A')}
    groups = {}
    for row in data['runs']:
        key = (row['round'], row['case'], row['threads'], row.get('variant', 'A'))
        assert key in expected, key
        assert row['errors'] == 0, row
        assert row['checksum'] == (row['operations'] + 100 * row['threads']) * 534, row
        groups.setdefault(key, []).append(row)
    assert groups.keys() == expected, ('missing micro cases', expected - groups.keys())
    assert all((len(rows) == (2 if paired else 1) for rows in groups.values())), 'duplicate/missing ABBA'
    return groups

def validate_http(data):
    expected = set(itertools.product(range(1, 3), ['db', 'plaintext', 'json', 'echo-1024'], [1, 8, 32, 128, 512, 1024], range(4)))
    completed = {}
    failed = []
    for row in data['runs']:
        key = tuple((row[k] for k in ['cycle', 'workload', 'connections', 'position']))
        assert key in expected, key
        if 'failure' in row:
            failed.append(row)
            continue
        assert key not in completed, ('duplicate', key)
        assert row['variant'] == 'ABBA'[row['position']], row
        assert len(row['wire_checks']) == 7, row
        if row.get('forced_cleanup'):
            row['forced_runner_cleanup'] = True
        completed[key] = row
    assert completed.keys() == expected, ('incomplete HTTP', len(completed), len(expected))
    return (completed, failed)

def main():
    ordinary = json.loads((base / 'raw/micro-before.json').read_text())
    paired = json.loads((base / 'raw/micro-paired.json').read_text())
    validate_micro(ordinary)
    validate_micro(paired, True)
    rows = []
    for source in ['micro-before', 'micro-paired', 'diagnostic-before', 'diagnostic-candidate']:
        for r in json.loads((base / f'raw/{source}.json').read_text())['runs']:
            row = {k: r[k] for k in ['case', 'threads', 'round', 'operations', 'elapsed_ns', 'p50_ns', 'p95_ns', 'p99_ns', 'errors', 'checksum', 'diagnostics', 'allocations', 'frees', 'bytes', 'peak_sum_bytes', 'cpu_seconds', 'process_wall_seconds']}
            row.update(process_cpu_percent=100 * r['cpu_seconds'] / r['process_wall_seconds'], source=source, variant=r.get('variant', 'A'), ops_per_second=r['operations'] * 1000000000.0 / r['elapsed_ns'], aggregate_ns_per_op=r['elapsed_ns'] / r['operations'])
            for name, value in zip(['pool_acquire', 'sqlite_prepare', 'stmt_wrapper_alloc', 'bind', 'step', 'row_decode', 'row_copy', 'stmt_finalize', 'pool_release', 'json_serialize'], r['stage_ns']):
                row[name + '_ns_per_op'] = value / r['operations'] if r['diagnostics'] else ''
            if not r['diagnostics']:
                for field in ['allocations', 'frees', 'bytes', 'peak_sum_bytes']:
                    row[field] = ''
            rows.append(row)
    with (base / 'microbenchmark.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]), lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)
    lines = ['# Microbenchmark results', '', 'Three ABBA cycles; each cell has six observations/variant. Medians, all errors retained.', 'A/B labels in this table mean frozen binary variants; Case A/B means API path.', 'Latency clock pairs are enabled in both ordinary micro executables. Process CPU includes warmup/start/teardown.', '', '| Case | Threads | Before ops/s | Candidate ops/s | Change % | Before P99 ns | Candidate P99 ns |', '|---|---:|---:|---:|---:|---:|---:|']
    for case, t in itertools.product('ABCDEF', [1, 8, 32, 128]):
        a = [r for r in paired['runs'] if r['case'] == case and r['threads'] == t and (r['variant'] == 'A')]
        b = [r for r in paired['runs'] if r['case'] == case and r['threads'] == t and (r['variant'] == 'B')]
        med = lambda rs, key: statistics.median((r[key] for r in rs))
        rate = lambda rs: statistics.median((r['operations'] * 1000000000.0 / r['elapsed_ns'] for r in rs))
        lines.append(f"| {case} | {t} | {rate(a):.0f} | {rate(b):.0f} | {(rate(b) / rate(a) - 1) * 100:+.2f} | {med(a, 'p99_ns'):.0f} | {med(b, 'p99_ns'):.0f} |")
    (base / 'microbenchmark.md').write_text('\n'.join(lines) + '\n')
    http = json.loads((base / 'raw/http-candidate.json').read_text())
    complete, failed = validate_http(http)
    lines = ['# Frozen HTTP before/candidate comparison', '', 'Candidate rejected and reverted. The final production fix retains the wrapper;', 'these measurements are not claimed as shipped throughput improvements.', '', f"Two ABBA cycles per cell, four observations/variant, {http['warmup']} s warmup / {http['duration']} s measurement.", 'Exploratory paired screen, not competitive certification. One server/load generator at a time.', 'HTTP/1.1 loopback, ReleaseFast, identical eight-connection SQLite configuration.', 'Median round percentiles (not pooled); errors are separate from completed-request latencies.', 'Server CPU: one core=100%; RSS: median sampled round mean.', '', '| Workload | Connections | Before 200/s | Candidate 200/s | Change % | Before P95 ms | Candidate P95 ms | Before P99 ms | Candidate P99 ms | Before CPU % | Candidate CPU % | Before RSS KiB | Candidate RSS KiB | Client errors A/B |', '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
    summaries = []
    for workload, c in itertools.product(['db', 'plaintext', 'json', 'echo-1024'], [1, 8, 32, 128, 512, 1024]):
        values = {v: [r for r in complete.values() if r['workload'] == workload and r['connections'] == c and (r['variant'] == v)] for v in 'AB'}
        a, b = [metrics(values[v]) for v in 'AB']
        delta = (b['http_200_per_second'] / a['http_200_per_second'] - 1) * 100
        summaries.append(dict(workload=workload, connections=c, before=a, candidate=b, change_percent=delta, round_rates={v: [r['oha']['statusCodeDistribution'].get('200', 0) / r['oha']['summary']['total'] for r in values[v]] for v in 'AB'}))
        lines.append(f"| {workload} | {c} | {a['http_200_per_second']:.0f} | {b['http_200_per_second']:.0f} | {delta:+.2f} | {a['p95_ms']:.3f} | {b['p95_ms']:.3f} | {a['p99_ms']:.3f} | {b['p99_ms']:.3f} | {a['cpu_percent']:.1f} | {b['cpu_percent']:.1f} | {a['rss_kib']:.0f} | {b['rss_kib']:.0f} | {a['client_errors']}/{b['client_errors']} |")
    (base / 'before-after.md').write_text('\n'.join(lines) + '\n')
    (base / 'raw/http-summary.json').write_text(json.dumps(dict(completed_cases=len(complete), failed_attempts=failed, comparisons=summaries), indent=2) + '\n')
    print('Validated 72 initial micro, 288 paired micro, 192 HTTP cases; wrote CSV and reports')
if __name__ == '__main__':
    main()
