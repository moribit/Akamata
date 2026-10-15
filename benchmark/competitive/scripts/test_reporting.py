"""Offline regression checks for evidence reporting, without starting load."""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from measure import runtime_reports, owned_load, require_disk_reserve
from compare_matrix import validate, compare, BASE, AFTER, WORKLOADS, CONNECTIONS
from zap_cleanup import cleanup as cleanup_zap


class ReportingTests(unittest.TestCase):
    def test_zap_cleanup_respects_payload_owner_window_and_links(self):
        import os
        import time
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            since = time.time() - 1
            for name, body in (("facil_io_tmpfile_full", b"x" * 65536),
                               ("facil_io_tmpfile_partial", b"x" * 40769),
                               ("facil_io_tmpfile_other", b"not benchmark data"),
                               ("unrelated", b"x" * 65536),
                               ("facil_io_tmpfile_old", b"x")):
                (root / name).write_bytes(body)
            os.utime(root / "facil_io_tmpfile_old", (since - 10, since - 10))
            (root / "facil_io_tmpfile_symlink").symlink_to(root / "unrelated")
            os.link(root / "unrelated", root / "facil_io_tmpfile_hardlink")
            report = cleanup_zap(root, since, time.time() + 1)
            self.assertEqual(2, report["removed_files"])
            self.assertEqual({"facil_io_tmpfile_other", "facil_io_tmpfile_old", "unrelated",
                              "facil_io_tmpfile_symlink", "facil_io_tmpfile_hardlink"},
                             {p.name for p in root.iterdir()})

    def matrix(self, frameworks):
        import itertools
        return {"warmup_seconds": 10, "duration_seconds": 30, "rounds": 5,
                "os": "fixture", "cpu_count": 8, "oha": "fixture",
                "binaries": dict.fromkeys(frameworks),
                "runs": [{"framework": f, "workload": w, "connections": c, "round": n,
                          "wire_checks": [None] * 7, "cpu_percent": 100,
                          "rss_mean_kib": 1000, "threads_peak": 8,
                          "oha": {"summary": {"total": 30},
                                  "statusCodeDistribution": {"200": 3000, "503": 1},
                                  "errorDistribution": {"timeout": 2},
                                  "latencyPercentiles": dict.fromkeys(("p50", "p95", "p99", "p99.9"), .001)}}
                         for f, w, c, n in itertools.product(frameworks, WORKLOADS, CONNECTIONS, range(1, 6))]}

    def test_full_matrix_comparison_keeps_errors(self):
        report = compare(self.matrix(BASE), self.matrix(AFTER))
        self.assertEqual(1260, report["baseline_cases"])
        self.assertEqual(630, report["after_cases"])
        first = report["comparisons"][0]
        self.assertEqual(100, first["after"]["http_200_per_second"])
        self.assertEqual(10, first["after"]["client_errors"])
        self.assertEqual(5, first["after"]["non_200"])
        self.assertEqual(0, first["throughput_change_percent"])

    def test_matrix_rejects_missing_duplicate_and_drift(self):
        data = self.matrix(BASE)
        row = data["runs"].pop()
        with self.assertRaisesRegex(ValueError, "incomplete matrix"):
            validate(data, BASE)
        data["runs"].extend([row, row])
        with self.assertRaisesRegex(ValueError, "duplicate completed case"):
            validate(data, BASE)
        after = self.matrix(AFTER)
        after["os"] = "other"
        with self.assertRaisesRegex(ValueError, "environment drift"):
            compare(self.matrix(BASE), after)

    def test_disk_reserve_fails_before_case_admission(self):
        from collections import namedtuple
        usage = namedtuple("usage", "total used free")
        with patch("measure.shutil.disk_usage", return_value=usage(2000, 1500, 500)):
            with self.assertRaisesRegex(RuntimeError, "checkpoint retained, no case started"):
                require_disk_reserve(Path("."), reserve_bytes=1000)
        with patch("measure.shutil.disk_usage", return_value=usage(2000, 1000, 1000)) as probe:
            require_disk_reserve(Path("."), reserve_bytes=1000)
            self.assertEqual(2, probe.call_count)

    def test_interrupted_owner_reaps_its_load_generator(self):
        with tempfile.TemporaryFile() as out, tempfile.TemporaryFile() as err:
            with self.assertRaisesRegex(RuntimeError, "interrupt"):
                with owned_load([sys.executable, "-c", "import time; time.sleep(60)"], out, err) as child:
                    raise RuntimeError("interrupt")
            self.assertIsNotNone(child.poll())
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
