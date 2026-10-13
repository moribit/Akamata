#!/usr/bin/env python3
"""Inclusive attribution, never a sum of mutually exclusive CPU costs."""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    args = parser.parse_args()
    data = json.loads(Path(args.input).read_text())
    print(f"# Runtime attribution\n\nEvidence: `{args.input}`. This is an **instrumented diagnostic**, not normal throughput evidence.\n")
    print("Counters include startup wire checks, warmup and measurement. Denominator: parsed request counter, including requests whose responses may fail. Wall/CPU spans are inclusive, overlapping and non-additive. Allocation counts are amortized framework allocator calls including startup, not logical arena allocations or SQLite/kernel/stack memory.\n")
    print("| Runtime | Workload | Connections | Parsed requests | Stage | Calls/request | Wall us/request | CPU us/request |")
    print("|---|---|---:|---:|---|---:|---:|---:|")
    kinds = ("accept_wait", "thread_spawn", "read", "parse", "peer_ip", "dispatch", "serialize", "deadline_clear", "enqueue", "queue_wait", "completion_wait", "selector_update", "selector_wait", "send", "poll_call", "readvec_call", "recv_call", "send_call", "selector_add", "selector_modify", "selector_delete", "wake_write", "mutex_lock")
    for row in data["runs"]:
        costs = row.get("runtime_cost")
        if not costs or not costs.get("request", {}).get("count"):
            print(f"Missing request attribution: {row['framework']} / {row['workload']} / {row['connections']}")
            continue
        count = costs["request"]["count"]
        for kind in kinds:
            value = costs.get(kind)
            if value is None:
                continue
            print(f"| {row['framework']} | {row['workload']} | {row['connections']} | {count} | {kind} | {value['count'] / count:.4f} | {value['wall_ns'] / count / 1000:.3f} | {value['cpu_ns'] / count / 1000:.3f} |")
    print("\n## Errors and allocator cleanup\n")
    print("| Runtime | Workload | Connections | Warmup client errors | Measurement client errors | Allocator calls/parsed request | Framework live bytes at exit |")
    print("|---|---|---:|---:|---:|---:|---:|")
    for row in data["runs"]:
        costs = row.get("runtime_cost", {})
        count = costs.get("request", {}).get("count", 0)
        stats = row.get("allocator", {})
        calls = f"{stats['calls'] / count:.6f}" if count and "calls" in stats else "unknown"
        warm = sum(row.get("warmup", {}).get("oha", {}).get("errorDistribution", {}).values())
        errors = sum(row.get("oha", {}).get("errorDistribution", {}).values())
        print(f"| {row['framework']} | {row['workload']} | {row['connections']} | {warm} | {errors} | {calls} | {stats.get('live', 'unknown')} |")
    print("\nAn error's absence from a diagnostic counter is not proof of a kernel or client cause. High-concurrency connection/reset errors remain unresolved until reproduced with controlled admission/burst diagnostics. No exclusive percentage of the throughput gap explained is claimed.")


if __name__ == "__main__":
    main()
