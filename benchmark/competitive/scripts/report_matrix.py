#!/usr/bin/env python3
"""Reproduce final evidence tables from complete matrices; no load or builds."""
import collections
import hashlib
import json
from pathlib import Path

from compare_matrix import AFTER, BASE, metrics, validate

ROOT = Path(__file__).resolve().parents[3] / "benchmark-results/competitive"


def main():
    data = [json.loads((ROOT / "raw" / name).read_text())
            for name in ("native-baseline.json", "native-after.json")]
    validated = [validate(d, names) for d, names in zip(data, (BASE, AFTER))]
    for field in ("os", "cpu_count", "oha", "warmup_seconds", "duration_seconds", "rounds"):
        if data[0][field] != data[1][field]:
            raise ValueError(f"environment drift: {field}")
    groups = {}
    evidence = []
    for d, (rows, failed), name in zip(data, validated, ("native-baseline.json", "native-after.json")):
        by_framework = {}
        for framework in d["binaries"]:
            selected = [r for r in rows.values() if r["framework"] == framework]
            errors = collections.Counter()
            for r in selected:
                errors.update(r["oha"]["errorDistribution"])
                key = (framework, r["workload"], r["connections"])
                groups.setdefault(key, []).append(r)
            by_framework[framework] = {
                "client_errors": dict(errors),
                "non_200": sum(sum(n for s, n in r["oha"]["statusCodeDistribution"].items()
                                   if s != "200") for r in selected),
                "server_exits": dict(collections.Counter(str(r.get("server_exit")) for r in selected)),
            }
        evidence.append({"path": "raw/" + name,
                         "sha256": hashlib.sha256((ROOT / "raw" / name).read_bytes()).hexdigest(),
                         "distinct_cases": len(rows), "failed_attempts": len(failed),
                         "excluded_prior_cases": len(d.get("excluded_runs", [])),
                         "forced_cleanup": sum(bool(r.get("forced_runner_cleanup")) for r in rows.values()),
                         "observed_load_wall_seconds": [min(r["measurement_wall_seconds"] for r in rows.values()),
                                                        max(r["measurement_wall_seconds"] for r in rows.values())],
                         "frameworks": by_framework})
    result = {"complete": True, "environment": {k: data[0][k] for k in (
        "os", "cpu_count", "oha", "warmup_seconds", "duration_seconds", "rounds")},
              "evidence": evidence, "production_gate": "unchanged; Reactor fail-closed"}
    (ROOT / "raw/matrix-validation.json").write_text(json.dumps(result, indent=2) + "\n")

    def get(f, w, c):
        return metrics(groups[f, w, c])

    lines = ["# Completed matrix: decision evidence", "",
             "Apple M2, macOS 27.0, ReleaseFast Akamata, HTTP/1.1 loopback, oha 1.15.0.",
             "Warmup 10 s + measurement 30 s × five rounds; medians of all rounds.",
             "Latency is median of round percentiles for completed requests, not pooled latency or a timeout-inclusive SLO.",
             "CPU: one core = 100%. RSS is median sampled round mean. All client errors retained.",
             "Exact source/toolchain/binary identities and invocations are in the raw matrices and manifests.", "",
             "## Observed Threaded before/after at 32 connections", "",
             "Separate time cohorts: observed differences are not causal optimization estimates.", "",
             "| Workload | Before HTTP 200/s | After HTTP 200/s | Change % | Before P99 ms | After P99 ms | Before CPU % | After CPU % | Before RSS KiB | After RSS KiB | Before/after client errors |",
             "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"]
    for w in ("plaintext", "json", "routing", "db", "echo-64", "echo-1024", "echo-65536"):
        b, a = get("akamata-threaded", w, 32), get("akamata-threaded-after", w, 32)
        lines.append(f"| {w} | {b['http_200_per_second']:,.0f} | {a['http_200_per_second']:,.0f} | "
                     f"{100*(a['http_200_per_second']/b['http_200_per_second']-1):+.1f} | "
                     f"{b['p99_ms']:.3f} | {a['p99_ms']:.3f} | {b['cpu_percent']:.1f} | {a['cpu_percent']:.1f} | "
                     f"{b['rss_kib']:,.0f} | {a['rss_kib']:,.0f} | {b['client_errors']} / {a['client_errors']} |")
    lines += ["", "## Final runtime cohort", "",
              "| Workload | Connections | Runtime | HTTP 200/s | vs final Threaded % | P95 ms | P99 ms | CPU % | RSS MiB | Threads | Client errors |",
              "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|"]
    for c in (32, 512, 1024):
        for w in ("plaintext", "json", "db", "echo-1024", "echo-65536"):
            t = get("akamata-threaded-after", w, c)
            for f in AFTER:
                a = get(f, w, c)
                lines.append(f"| {w} | {c} | {f} | {a['http_200_per_second']:,.0f} | "
                             f"{100*(a['http_200_per_second']/t['http_200_per_second']-1):+.1f} | "
                             f"{a['p95_ms']:.3f} | {a['p99_ms']:.3f} | {a['cpu_percent']:.1f} | "
                             f"{a['rss_kib']/1024:.1f} | {a['threads']:g} | {a['client_errors']} |")
    lines += ["", "## Baseline competitive cohort at 32 connections", "",
              "Compare competitors within this cohort; do not rank final Akamata against earlier competitor runs.", "",
              "| Workload | Framework | HTTP 200/s | P95 ms | P99 ms | CPU % | RSS MiB | Client errors |",
              "|---|---|---:|---:|---:|---:|---:|---:|"]
    for w in ("plaintext", "json", "db", "echo-1024"):
        for f in BASE:
            a = get(f, w, 32)
            lines.append(f"| {w} | {f} | {a['http_200_per_second']:,.0f} | {a['p95_ms']:.3f} | "
                         f"{a['p99_ms']:.3f} | {a['cpu_percent']:.1f} | {a['rss_kib']/1024:.1f} | {a['client_errors']} |")
    lines += ["", "## Round spread: plaintext at 32 connections", "",
              "This spread is retained rather than selecting the best round. It limits attribution and ranking.", "",
              "| Framework | Round 1 | Round 2 | Round 3 | Round 4 | Round 5 |", "|---|---:|---:|---:|---:|---:|"]
    for f in (*BASE, *AFTER):
        rows = sorted(groups[f, "plaintext", 32], key=lambda r: r["round"])
        values = [r["oha"]["statusCodeDistribution"].get("200", 0) / r["oha"]["summary"]["total"] for r in rows]
        lines.append("| " + f + " | " + " | ".join(f"{v:,.0f}" for v in values) + " |")
    failures = sum(e["failed_attempts"] for e in evidence)
    forced = sum(e["forced_cleanup"] for e in evidence)
    non200 = sum(f["non_200"] for e in evidence for f in e["frameworks"].values())
    lines += ["", "## Completion and errors", "",
              f"1260 baseline + 630 after distinct cases. Failed attempts: {failures}; forced runner kills: {forced}; non-200 responses: {non200}.",
              "Nine pre-cleanup zap large-echo cases remain excluded raw evidence and were replaced, independent of performance.",
              "Client error reasons and server exit codes are preserved in [validation](raw/matrix-validation.json).",
              "Go's -2 exits are the runner's SIGINT shutdown, not forced runner kills or a graceful-drain proof.",
              "See the full baseline/after/matrix tables for all 1/8/32/128/512/1024 connection levels and seven workloads.", ""]
    (ROOT / "decision-evidence.md").write_text("\n".join(lines))


if __name__ == "__main__":
    main()
