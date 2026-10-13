"""Offline regression checks for evidence reporting, without starting load."""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from measure import runtime_reports


class ReportingTests(unittest.TestCase):
    def test_runtime_diagnostics_preserve_unknown_counters(self):
        reports = runtime_reports('info: started\nRUNTIME_COST {"future_counter":{"count":7}}\nBENCH_STATS {"live":0}\n')
        self.assertEqual(7, reports["runtime_cost"]["future_counter"]["count"])
        self.assertEqual(0, reports["allocator"]["live"])
        with self.assertRaisesRegex(ValueError, "duplicate"):
            runtime_reports('RUNTIME_COST {}\nRUNTIME_COST {}\n')

    def test_all_rounds_and_failures_remain_visible(self):
        def row(rate, errors):
            return {"framework": "fixture", "workload": "plaintext", "connections": 32,
                    "round": 1, "cpu_percent": 100, "rss_mean_kib": 1000, "threads_peak": 8,
                    "oha": {"summary": {"requestsPerSec": rate + errors + 2, "total": 1},
                            "latencyPercentiles": {k: .001 for k in ("p50", "p95", "p99", "p99.9")},
                            "errorDistribution": {"timeout": errors}, "statusCodeDistribution": {"200": rate, "503": 2}}}
        data = {"classification": "exploratory", "runs": [row(100, 1), row(300, 2), row(2000, 3),
                {"framework": "fixture", "workload": "plaintext", "connections": 32, "round": 4, "failure": "spawn failed"}]}
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "raw.json"
            path.write_text(json.dumps(data))
            text = subprocess.check_output([sys.executable, str(Path(__file__).with_name("summarize.py")), str(path)], text=True)
        self.assertIn("| 3 | 300 | 304 |", text)  # successful rate distinct from attempts
        self.assertIn("| 6 | 6 | 0.4975 |", text)  # non-200 and client errors retained
        self.assertIn("Failed cases: 1", text)
        self.assertIn("spawn failed", text)
        self.assertIn("not pooled percentiles", text)

    def test_calibration_rejects_unequal_connection_split(self):
        completed = subprocess.run([sys.executable, str(Path(__file__).with_name("calibrate.py")),
                                    "unused.json", "--output", "unused.json", "--connections", "31"], capture_output=True, text=True)
        self.assertEqual(2, completed.returncode)
        self.assertIn("must be even", completed.stderr)

    def test_idle_rejects_unsafe_connection_count(self):
        completed = subprocess.run([sys.executable, str(Path(__file__).with_name("idle.py")),
                                    "unused.json", "--output", "unused.json", "--connections", "1025"], capture_output=True, text=True)
        self.assertEqual(2, completed.returncode)
        self.assertIn("safe connection range", completed.stderr)


if __name__ == "__main__":
    unittest.main()
