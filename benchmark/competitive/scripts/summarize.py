#!/usr/bin/env python3
"""Report every measured round; do not discard errors or combine percentiles."""
import argparse
import collections
import json
import statistics
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    args = parser.parse_args()
    data = json.loads(Path(args.input).read_text())
    groups = collections.defaultdict(list)
    failed = []
    for row in data["runs"]:
        if "failure" in row or "oha" not in row:
            failed.append(row)
        else:
            groups[row["workload"], row["connections"], row["framework"]].append(row)
    print(f"Evidence: `{args.input}`; classification: {data['classification']}.")
    print("\nMedians of all completed rounds. Latency columns are medians of round percentiles, not pooled percentiles. CPU: one core = 100%. RSS: median of round sampled means. Errors are summed, never removed.\n")
    print("| Workload | Connections | Framework | Rounds | req/s | P50 ms | P95 ms | P99 ms | P99.9 ms | CPU % | RSS KiB | Threads | Non-200 | Client errors |")
    print("|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for (workload, connections, framework), rows in sorted(groups.items()):
        med = lambda fn: statistics.median(fn(row) for row in rows)
        latency = [med(lambda row: row["oha"]["latencyPercentiles"][key] * 1000) for key in ("p50", "p95", "p99", "p99.9")]
        errors = sum(sum(row["oha"]["errorDistribution"].values()) for row in rows)
        non200 = sum(sum(count for status, count in row["oha"]["statusCodeDistribution"].items() if status != "200") for row in rows)
        print(f"| {workload} | {connections} | {framework} | {len(rows)} | {med(lambda row: row['oha']['summary']['requestsPerSec']):,.0f} | " + " | ".join(f"{value:.3f}" for value in latency) + f" | {med(lambda row: row['cpu_percent']):.1f} | {med(lambda row: row['rss_mean_kib']):,.0f} | {med(lambda row: row['threads_peak']):g} | {non200} | {errors} |")
    print(f"\nFailed cases: {len(failed)}. Full requested matrix completion is not implied by a subset table.")
    for row in failed:
        print(f"- {row['framework']} / {row['workload']} / {row['connections']} / round {row['round']}: {row.get('failure', 'incomplete')}")


if __name__ == "__main__":
    main()
