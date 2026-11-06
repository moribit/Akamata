#!/usr/bin/env python3
"""Collect public Actions timing/artifacts and render comparable CI reports.

python3 tools/ci/measure.py collect RUN_ID ...
python3 tools/ci/measure.py report
Requires authenticated gh; never changes repository settings or workflow runs.
"""
import argparse
from datetime import datetime
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / "docs/evidence/ci-performance/raw"
REPO = "moribit/Akamata"


def api(path):
    return json.loads(subprocess.check_output(["gh", "api", f"repos/{REPO}/{path}"], text=True))


def seconds(start, end):
    return (datetime.fromisoformat(end.replace("Z", "+00:00")) -
            datetime.fromisoformat(start.replace("Z", "+00:00"))).total_seconds()


def summarize(run, jobs):
    finished = [j for j in jobs if j.get("started_at") and j.get("completed_at")]
    return {"id": run["id"], "sha": run["head_sha"], "conclusion": run["conclusion"],
            "wall_seconds": max((seconds(run["created_at"], j["completed_at"]) for j in finished), default=0),
            "job_seconds": sum(seconds(j["started_at"], j["completed_at"]) for j in finished),
            "jobs": [{"name": j["name"], "conclusion": j["conclusion"],
                      "seconds": seconds(j["started_at"], j["completed_at"]),
                      "start_offset": seconds(run["created_at"], j["started_at"]),
                      "steps": [{"name": s["name"], "conclusion": s["conclusion"],
                                 "seconds": seconds(s["started_at"], s["completed_at"])}
                                for s in j["steps"] if s.get("started_at") and s.get("completed_at")]}
                     for j in finished]}


def collect(run_id):
    directory = DEST / str(run_id)
    directory.mkdir(parents=True, exist_ok=True)
    run = api(f"actions/runs/{run_id}")
    jobs = api(f"actions/runs/{run_id}/jobs?per_page=100")
    assert jobs["total_count"] <= 100, "Add pagination before measuring this workflow"
    artifacts = api(f"actions/runs/{run_id}/artifacts?per_page=100")
    (directory / "run.json").write_text(json.dumps({k: run[k] for k in (
        "id", "head_sha", "event", "status", "conclusion", "created_at", "updated_at", "html_url", "run_attempt")}, indent=2) + "\n")
    (directory / "jobs.json").write_text(json.dumps(jobs, indent=2) + "\n")
    (directory / "artifacts.json").write_text(json.dumps(artifacts, indent=2) + "\n")
    (directory / "summary.json").write_text(json.dumps(summarize(run, jobs["jobs"]), indent=2) + "\n")
    for artifact in artifacts["artifacts"]:
        if artifact["name"].startswith(("living-examples-", "cli-command-timing")) and not artifact["expired"]:
            target = directory / artifact["name"]
            if target.exists():
                continue
            subprocess.run(["gh", "run", "download", str(run_id), "--repo", REPO,
                            "--name", artifact["name"], "--dir", str(target)], check=True)
    (directory / "cache-inventory.json").write_text(json.dumps(api("actions/caches?per_page=100"), indent=2) + "\n")
    observations = []
    for job in jobs["jobs"]:
        if job["name"] in ("native-openssl", "living examples (ubuntu-latest)", "living examples (macos-latest)", "cli init smoke test") and job["status"] == "completed":
            log = subprocess.check_output(["gh", "api", f"repos/{REPO}/actions/jobs/{job['id']}/logs"], text=True)
            selected = [line for line in log.splitlines() if any(token in line for token in (
                "Cache hit (key", "Cache miss: leaving Zig", "Cache directory", "Cache saved", "Cache Size:",
                "Build Summary:", "tests passed", "run test", "##[error]", "##[warning]"))]
            observations.append({"job": job["name"], "id": job["id"], "observations": selected})
    (directory / "cache-and-tests.json").write_text(json.dumps(observations, indent=2) + "\n")
    print(f"Collected {run_id}: {run['status']} / {run['conclusion']}")


def report():
    lines = ["# CI timing measurements", "", "Times are seconds. Wall includes runner queues; job sum is elapsed execution, not billed minutes.",
             "Only successful completed runs are comparable. No estimate is presented as a measured improvement.", "",
             "| Run | SHA | Result | Wall | Job sum |", "|---|---|---|---:|---:|"]
    for file in sorted(DEST.glob("*/summary.json")):
        d = json.loads(file.read_text())
        lines.append(f"| [{d['id']}](https://github.com/{REPO}/actions/runs/{d['id']}) | {d['sha'][:7]} | {d['conclusion']} | {d['wall_seconds']:.0f} | {d['job_seconds']:.0f} |")
    for file in sorted(DEST.glob("*/summary.json")):
        d = json.loads(file.read_text())
        lines += ["", f"## Run {d['id']}", "", "| Job | Start offset | Duration | Result |", "|---|---:|---:|---|"]
        for j in d["jobs"]:
            lines.append(f"| {j['name']} | {j['start_offset']:.0f} | {j['seconds']:.0f} | {j['conclusion']} |")
        for artifact in sorted(file.parent.glob("living-examples-*/*.json")):
            evidence = json.loads(artifact.read_text())
            commands = evidence["commands"]
            lines += ["", f"### {artifact.parent.name}: {len(commands)} commands", "",
                      "| Command | Seconds |", "|---|---:|"]
            for c in sorted(commands, key=lambda c: c["seconds"], reverse=True)[:16]:
                lines.append(f"| `{' '.join(c['command'])}` | {c['seconds']:.3f} |")
    (DEST.parent / "measurements.md").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["collect", "report"])
    parser.add_argument("runs", nargs="*", type=int)
    args = parser.parse_args()
    if args.action == "collect":
        for run_id in args.runs:
            collect(run_id)
    else:
        report()
