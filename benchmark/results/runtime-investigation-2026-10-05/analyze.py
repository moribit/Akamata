#!/usr/bin/env python3
"""Derive attribution and comparisons; retain original raw data unchanged."""
import json
from pathlib import Path
import re
from statistics import mean

ROOT = Path(__file__).resolve().parent
out = {"attribution": {}, "performance": {}, "memory": {}, "syscalls": {}, "limitations": [
    "Span CPU/wall is inclusive; nested regions cannot be summed",
    "Threaded read wall includes readiness wait; Reactor recv timing excludes selector wait",
    "Atomic counters and clock_gettime perturb scheduling; instrumented throughput is not optimization evidence",
    "Observed throughput gap closure is intervention effect, not an exclusive CPU attribution percentage",
]}
for file in ROOT.rglob("*.json"):
    if file.name in ("analysis.json", "environment.json"):
        continue
    try:
        data = json.loads(file.read_text())
    except ValueError:
        continue
    if not isinstance(data, dict):
        continue
    key = str(file.relative_to(ROOT))
    runs = data.get("runs", [])
    attributed = []
    for r in runs:
        if "runtime_cost" not in r:
            continue
        c = r["runtime_cost"]
        n = c["request"]["count"]
        if not n:
            continue
        attributed.append({"label": r["label"], "kind": r["kind"], "connections": r["connections"], "endpoint": r["endpoint"], "requests": n, "intervals": {
            name: {"count_per_request": v["count"] / n, "wall_us_per_request": v["wall_ns"] / n / 1000, "cpu_us_per_request": v["cpu_ns"] / n / 1000}
            for name, v in c.items()
        }})
    if attributed:
        out["attribution"][key] = attributed
    rows = []
    cases = {(r["kind"], r["connections"], r["endpoint"]) for r in runs if "oha" in r}
    for kind, connections, endpoint in sorted(cases):
        labels = {}
        for label in sorted({r["label"] for r in runs if "oha" in r}):
            selected = [r for r in runs if r.get("kind") == kind and r.get("connections") == connections and r.get("endpoint") == endpoint and r.get("label") == label and "oha" in r]
            if not selected:
                continue
            labels[label] = {
                "rps": mean(r["oha"]["summary"]["requestsPerSec"] for r in selected),
                "latency_ms": {p: mean(r["oha"]["latencyPercentiles"][p] * 1000 for r in selected) for p in ("p50", "p95", "p99")},
                "cpu_percent": mean(r["cpu_percent"] for r in selected),
                "rss_kib": mean(r["rss_mean_kib"] for r in selected),
                "threads_peak": max(r["threads_peak"] for r in selected),
                "allocation_calls": mean(r.get("allocator", {}).get("calls", 0) for r in selected),
                "shutdown_ms": mean(r["shutdown_ms"] for r in selected),
            }
        row = {"cpu_attribution_enabled": bool(attributed), "kind": kind, "connections": connections, "endpoint": endpoint, "labels": labels}
        if "before" in labels and "reactor" in labels:
            row["reactor_improvement_percent"] = (labels["reactor"]["rps"] / labels["before"]["rps"] - 1) * 100
            if "threaded" in labels:
                row["remaining_vs_threaded_percent"] = (labels["reactor"]["rps"] / labels["threaded"]["rps"] - 1) * 100
                initial_gap = labels.get("threaded-before", labels["threaded"])["rps"] - labels["before"]["rps"]
                # A tiny/noisy denominator can produce misleading thousands
                # of percent; do not portray near-parity as precise attribution.
                native_before = labels.get("threaded-before", labels["threaded"])["rps"]
                row["initial_gap_percent"] = initial_gap / native_before * 100
                row["observed_gap_closed_percent"] = (labels["reactor"]["rps"] - labels["before"]["rps"]) / initial_gap * 100 if initial_gap >= native_before * .05 else None
        rows.append(row)
    if rows:
        out["performance"][key] = rows
    idle = [r for r in runs if r.get("scenario") == "idle"]
    if idle:
        out["memory"][key] = [{"adapter": r["adapter"], "count": r["count"], "resources": r["samples"][-1], "budget": r.get("runtime_memory"), "application": r.get("application_memory"), "establishment_ms": r["establishment_ms"], "broadcast_ms": r["broadcast_ms"], "shutdown_ms": r["shutdown_ms"], "clean": r["clean"]} for r in idle]
for file in ROOT.rglob("syscalls.txt"):
    load = json.loads((file.parent / "oha.json").read_text())
    requests = sum(load["statusCodeDistribution"].values())
    counts = {}
    for line in file.read_text().splitlines():
        match = re.match(r"\s*[\d.]+\s+[\d.]+\s+\d+\s+(\d+)\s+(?:(\d+)\s+)?([a-zA-Z_][\w]*|total)\s*$", line)
        if match:
            counts[match[3]] = {"calls": int(match[1]), "errors": int(match[2] or 0), "calls_per_request": int(match[1]) / requests}
    out["syscalls"][str(file.relative_to(ROOT))] = {"requests": requests, "counts": counts, "limitation": "ptrace perturbs scheduling; startup/shutdown included"}
(ROOT / "analysis.json").write_text(json.dumps(out, indent=2) + "\n")
print("Derived", len(out["attribution"]), "attribution matrices,", len(out["performance"]), "performance matrices,", len(out["memory"]), "memory trials,", len(out["syscalls"]), "syscall summaries")
