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
    from native_evidence import query
    frameworks = tuple(frameworks)
    arguments = ("baseline",) if frameworks == BASE else ("after",) if frameworks == AFTER else ("--frameworks", *frameworks)
    query("matrix", data, arguments=arguments)
    complete, failures = {}, []
    for row in data["runs"]:
        if "failure" in row or "oha" not in row:
            failures.append(row)
        else:
            key = tuple(row[k] for k in ("framework", "workload", "connections", "round"))
            complete[key] = row
    return complete, failures


def metrics(rows):
    from native_evidence import query
    return query("metrics", {"runs": rows})


def compare(before, after):
    from native_evidence import query
    return query("compare", before, after)


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
