"""Failure-path contract for the CI measurement helpers (no Zig/network)."""
import contextlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from command_timing import run
import living_examples


class TimingContract(unittest.TestCase):
    def test_exit_status_and_output_are_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.dict(os.environ, AKAMATA_CI_TIMING_DIR=directory):
                result = run([sys.executable, "-c", "print('diagnostic'); raise SystemExit(7)"],
                             capture_output=True, text=True)
            self.assertEqual(result.returncode, 7)
            self.assertEqual(result.stdout.strip(), "diagnostic")
            row = json.loads((Path(directory) / "scaffold-minimal.jsonl").read_text())
            self.assertEqual(row["returncode"], 7)
            self.assertGreater(row["seconds"], 0)

    def test_checked_failure_is_recorded(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.dict(os.environ, AKAMATA_CI_TIMING_DIR=directory):
                with self.assertRaises(subprocess.CalledProcessError):
                    run([sys.executable, "-c", "raise SystemExit(5)"], check=True)
            row = json.loads((Path(directory) / "scaffold-minimal.jsonl").read_text())
            self.assertEqual(row["returncode"], 5)

    def test_living_failure_saves_partial_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            report = Path(directory) / "partial.json"
            with patch.object(living_examples, "REPORT", report):
                with contextlib.redirect_stdout(io.StringIO()) as output:
                    with self.assertRaises(subprocess.CalledProcessError):
                        living_examples.run(sys.executable, "-c", "print('failure context'); raise SystemExit(9)")
            self.assertIn("failure context", output.getvalue())
            row = json.loads(report.read_text())["commands"][-1]
            self.assertEqual(row["returncode"], 9)


if __name__ == "__main__":
    unittest.main()
