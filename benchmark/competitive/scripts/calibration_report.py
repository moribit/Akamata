#!/usr/bin/env python3
"""Keep separate distributions; report only aggregate completion rate."""
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
    print(f"# Local generator calibration\n\nEvidence: `{args.input}`. Binary hashes, commands and individual oha distributions are retained there.\n")
    conditions = sorted({(r["total_connections"], r["warmup_seconds"], r["duration_seconds"]) for r in data["runs"]})
    print(f"One versus two generators at the same total connection count. Recorded (connections, warmup seconds, measurement seconds): {conditions}. Values below use all available rounds; a partial file is not a completed calibration.\n")
    print("| Framework | Generators | Rounds | Median completed HTTP 200/s | Min | Max | Median server CPU % | Client errors | Non-200 |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|---:|")
    for row in data["runs"]:
        if "measurement" not in row or "failure" in row:
            print(f"Failure/incomplete: {row['framework']}, round {row['round']}, generators {row['generators']}: {row.get('failure', 'incomplete')}")
            continue
        measurement = row["measurement"]
        # Common observed interval, not an average of generator percentiles.
        rate = sum(r["statusCodeDistribution"].get("200", 0) for r in measurement["individual_oha"]) / measurement["wall_seconds"]
        errors = sum(sum(r["errorDistribution"].values()) for r in measurement["individual_oha"])
        non200 = sum(sum(count for status, count in r["statusCodeDistribution"].items() if status != "200") for r in measurement["individual_oha"])
        groups[row["framework"], row["generators"]].append((rate, measurement["server_cpu_percent"], errors, non200))
    for (name, generators), rows in sorted(groups.items()):
        rates = [r[0] for r in rows]
        print(f"| {name} | {generators} | {len(rows)} | {statistics.median(rates):,.0f} | {min(rates):,.0f} | {max(rates):,.0f} | {statistics.median(r[1] for r in rows):.1f} | {sum(r[2] for r in rows)} | {sum(r[3] for r in rows)} |")
    print("\nSplitting a generator also changes scheduling and CPU contention on the same machine. No improvement from splitting does **not** prove unlimited generator headroom. This remains a local closed-loop measurement; dedicated remote generation is needed for stronger server-ceiling claims. Individual latency distributions are not pooled or averaged. CPU: one core = 100%.")


if __name__ == "__main__":
    main()
