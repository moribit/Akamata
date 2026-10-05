#!/usr/bin/env python3
"""Derive paired means and resource ranges without modifying original evidence."""
import json
from pathlib import Path
from statistics import mean

ROOT = Path(__file__).resolve().parent
result = {"cohorts": {}, "note": "Historical macOS session thread counts include the ps header; derived counts subtract one. Matrix counts are already correct."}
for name in ("ci-linux", "ci-macos", "ci-linux-after-deadline-fix", "ci-macos-after-deadline-fix"):
    base = ROOT / name / "certification"
    if not (base / "matrix.json").exists():
        continue
    matrix = json.loads((base / "matrix.json").read_text())
    paired = []
    for kind in ("keep_alive", "short_lived"):
        for connections in (4, 32, 128, 256):
            for endpoint in ("hello", "echo", "db/1"):
                entries = {}
                for label in ("threaded", "reactor"):
                    runs = [r for r in matrix["runs"] if r.get("kind") == kind and r.get("connections") == connections and r.get("endpoint") == endpoint and r.get("label") == label]
                    if not runs:
                        continue
                    entries[label] = {
                        "rps": mean(r["oha"]["summary"]["requestsPerSec"] for r in runs),
                        "latency_ms": {p: mean(r["oha"]["latencyPercentiles"][p] * 1000 for r in runs) for p in ("p50", "p95", "p99")},
                        "cpu_percent": mean(r["cpu_percent"] for r in runs),
                        "rss_kib": mean(r["rss_mean_kib"] for r in runs),
                        "threads_peak": max(r["threads_peak"] for r in runs),
                    }
                if len(entries) == 2:
                    paired.append({"kind": kind, "connections": connections, "endpoint": endpoint, **entries, "reactor_rps_delta_percent": (entries["reactor"]["rps"] / entries["threaded"]["rps"] - 1) * 100})
    sessions = json.loads((base / "sessions.json").read_text())
    soaks = []
    for run in sessions["runs"]:
        if run["scenario"] != "mixed-soak-races":
            continue
        samples = run["samples"]
        if "macos" in name and sessions.get("thread_count_method") != "ps-M-minus-header":
            samples = [{**s, "threads": max(0, s["threads"] - 1)} for s in samples]
        soaks.append({
            "adapter": run["adapter"], "elapsed_s": run.get("elapsed_s"),
            "http_max_ms": max(r["http_max_ms"] for r in run["mixed_results"]),
            "resources": {k: {"first": samples[0][k], "last": samples[-1][k], "min": min(s[k] for s in samples), "max": max(s[k] for s in samples)} for k in ("rss_kib", "fds", "threads", "cpu_percent")},
            "allocator_live": {"first": samples[0]["allocator"]["live"], "last": samples[-1]["allocator"]["live"], "min": min(s["allocator"]["live"] for s in samples), "max": max(s["allocator"]["live"] for s in samples)},
            "shutdown_ms": run["shutdown_ms"], "allocator_final": run["allocator_final"], "sessions_final": run["sessions_final"], "clean": run["clean"],
        })
    result["cohorts"][name] = {"source_sha": (base / "source-sha.txt").read_text().strip(), "platform": matrix["platform"], "binaries": matrix["binaries"], "paired": paired, "soaks": soaks, "passed": sessions["passed"], "long_soak_completed": sessions["long_soak_completed"]}
(ROOT / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
for name, cohort in result["cohorts"].items():
    print(name, cohort["source_sha"], cohort["passed"], cohort["long_soak_completed"])
    for row in cohort["paired"]:
        if row["kind"] == "keep_alive" and row["connections"] == 32:
            print(row["endpoint"], round(row["threaded"]["rps"]), round(row["reactor"]["rps"]), round(row["reactor_rps_delta_percent"], 1))
    for soak in cohort["soaks"]:
        print(soak["adapter"], round(soak["elapsed_s"], 2), "HTTP max", round(soak["http_max_ms"], 2), "clean", soak["clean"])
