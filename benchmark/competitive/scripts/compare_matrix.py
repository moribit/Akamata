#!/usr/bin/env python3
"""Validate full frozen matrices before generating before/after comparisons."""
import argparse
import hashlib
import itertools
import json
import statistics
from pathlib import Path

WORKLOADS = ("plaintext", "json", "routing", "db", "echo-64", "echo-1024", "echo-65536")
CONNECTIONS = (1, 8, 32, 128, 512, 1024)
BASE = ("akamata-threaded", "akamata-reactor", "actix", "axum", "go", "zap")
AFTER = ("akamata-threaded-after", "akamata-reactor-single-after", "akamata-reactor-sharded-after")


def validate(data, frameworks):
    for key, expected in (("warmup_seconds", 10), ("duration_seconds", 30), ("rounds", 5)):
        if data.get(key) != expected:
            raise ValueError(f"requested matrix requires {key}={expected}")
    if set(data["binaries"]) != set(frameworks):
        raise ValueError("unexpected frozen framework set")
    expected = set(itertools.product(frameworks, WORKLOADS, CONNECTIONS, range(1, 6)))
    complete, failures = {}, []
    for row in data["runs"]:
        key = tuple(row[k] for k in ("framework", "workload", "connections", "round"))
        if key not in expected:
            raise ValueError(f"unexpected case: {key}")
        if "failure" in row or "oha" not in row:
            failures.append(row)
            continue
        if key in complete:
            raise ValueError(f"duplicate completed case: {key}")
        if len(row.get("wire_checks", [])) != len(WORKLOADS):
            raise ValueError(f"missing wire conformance: {key}")
        complete[key] = row
    missing = expected - complete.keys()
    if missing:
        raise ValueError(f"incomplete matrix: {len(complete)}/{len(expected)} completed; "
                         f"first missing: {sorted(missing)[0]}")
    return complete, failures


def metrics(rows):
    med = lambda f: statistics.median(f(row) for row in rows)
    clients = sum(sum(r["oha"]["errorDistribution"].values()) for r in rows)
    non200 = sum(sum(n for status, n in r["oha"]["statusCodeDistribution"].items()
                     if status != "200") for r in rows)
    attempts = clients + sum(sum(r["oha"]["statusCodeDistribution"].values()) for r in rows)
    return {"http_200_per_second": med(lambda r: r["oha"]["statusCodeDistribution"].get("200", 0)
                                       / r["oha"]["summary"]["total"]),
            **{k + "_ms": med(lambda r: r["oha"]["latencyPercentiles"][k] * 1000)
               for k in ("p50", "p95", "p99", "p99.9")},
            "cpu_percent": med(lambda r: r["cpu_percent"]),
            "rss_kib": med(lambda r: r["rss_mean_kib"]),
            "threads": med(lambda r: r["threads_peak"]),
            "client_errors": clients, "non_200": non200,
            "error_percent": 100 * (clients + non200) / attempts if attempts else 0,
            "forced_cleanup": sum(bool(r.get("forced_runner_cleanup")) for r in rows),
            "server_exits": [r.get("server_exit") for r in rows]}


def compare(before, after):
    left, failed_left = validate(before, BASE)
    right, failed_right = validate(after, AFTER)
    for field in ("os", "cpu_count", "oha", "warmup_seconds", "duration_seconds", "rounds"):
        if before[field] != after[field]:
            raise ValueError(f"before/after environment drift: {field}")
    comparisons = []
    for workload, connections in itertools.product(WORKLOADS, CONNECTIONS):
        baseline = metrics([left["akamata-threaded", workload, connections, n] for n in range(1, 6)])
        for framework in AFTER:
            current = metrics([right[framework, workload, connections, n] for n in range(1, 6)])
            comparisons.append({"workload": workload, "connections": connections, "framework": framework,
                                "before_threaded": baseline, "after": current,
                                "throughput_change_percent": 100 * (current["http_200_per_second"]
                                                                     / baseline["http_200_per_second"] - 1)})
    return {"complete": True, "baseline_cases": len(left), "after_cases": len(right),
            "failed_attempts": {"baseline": failed_left, "after": failed_right},
            "excluded_prior_runs": {"baseline": before.get("excluded_runs", []),
                                    "after": after.get("excluded_runs", [])},
            "comparisons": comparisons}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline")
    parser.add_argument("after")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    paths = [Path(args.baseline), Path(args.after)]
    data = [json.loads(p.read_text()) for p in paths]
    result = compare(*data)  # No final report is written for an incomplete matrix.
    result["evidence"] = [{"path": str(p), "sha256": hashlib.sha256(p.read_bytes()).hexdigest(),
                           "binaries": d["binaries"], "invocations": d.get("invocations", [d["command"]])}
                          for p, d in zip(paths, data)]
    output = Path(args.output)
    output.with_suffix(".json").write_text(json.dumps(result, indent=2) + "\n")
    lines = ["# Full Native matrix comparison", "",
             "1260 baseline and 630 after cases; five 30-second rounds after 10-second warmup.",
             "Medians of all rounds; latency is median of round percentiles, not pooled.",
             "CPU: one core = 100%; RSS: median sampled round mean. All errors retained.", "",
             "| Workload | Connections | After runtime | Before HTTP 200/s | After HTTP 200/s | Change % | Before P99 ms | After P99 ms | Before CPU % | After CPU % | Before RSS KiB | After RSS KiB | After threads | After client errors | After non-200 | After forced cleanup |",
             "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"]
    for row in result["comparisons"]:
        b, a = row["before_threaded"], row["after"]
        values = [row["workload"], str(row["connections"]), row["framework"],
                  f"{b['http_200_per_second']:.0f}", f"{a['http_200_per_second']:.0f}",
                  f"{row['throughput_change_percent']:+.2f}", f"{b['p99_ms']:.3f}",
                  f"{a['p99_ms']:.3f}", f"{b['cpu_percent']:.1f}", f"{a['cpu_percent']:.1f}",
                  f"{b['rss_kib']:.0f}", f"{a['rss_kib']:.0f}", str(a['threads']),
                  str(a['client_errors']), str(a['non_200']), str(a['forced_cleanup'])]
        lines.append("| " + " | ".join(values) + " |")
    lines += ["", "Full P50/P95/P99/P99.9 and source/binary digests are in the adjacent JSON.",
              "Failed harness attempts remain in JSON; client errors remain in every metric.",
              "This Mac loopback matrix does not establish Linux or live Cloudflare performance.",
              "Runtime production admission requires separate Contract, stress/fault, TSan and idle-retention evidence.",
              "This reporting tool never changes the production gate.", ""]
    output.write_text("\n".join(lines))


if __name__ == "__main__":
    main()
