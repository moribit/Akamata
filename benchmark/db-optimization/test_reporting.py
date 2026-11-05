#!/usr/bin/env python3
"""Evidence guards must fail on missing, duplicated, or erroneous results."""
import copy, importlib.util, itertools, unittest
from pathlib import Path
spec = importlib.util.spec_from_file_location('db_report', Path(__file__).with_name('report.py'))
report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(report)

def micro():
    return {'runs': [dict(round=r, case=c, threads=t, variant=v, errors=0, operations=1000, checksum=(1000 + 100 * t) * 534) for r, c, t, v, n in itertools.product(range(1, 4), 'ABCDEF', [1, 8, 32, 128], 'AB', range(2))]}

def http():
    return {'runs': [dict(cycle=r, workload=w, connections=c, position=p, variant='ABBA'[p], wire_checks=[{}] * 7) for r, w, c, p in itertools.product(range(1, 3), ['db', 'plaintext', 'json', 'echo-1024'], [1, 8, 32, 128, 512, 1024], range(4))]}

class Evidence(unittest.TestCase):

    def test_complete_micro(self):
        report.validate_micro(micro(), True)

    def test_missing_micro(self):
        d = micro()
        d['runs'].pop()
        with self.assertRaises(AssertionError):
            report.validate_micro(d, True)

    def test_duplicate_micro(self):
        d = micro()
        d['runs'].append(d['runs'][0])
        with self.assertRaises(AssertionError):
            report.validate_micro(d, True)

    def test_micro_error(self):
        d = micro()
        d['runs'][0]['errors'] = 1
        with self.assertRaises(AssertionError):
            report.validate_micro(d, True)

    def test_micro_lost_row(self):
        d = micro()
        d['runs'][0]['checksum'] = 0
        with self.assertRaises(AssertionError):
            report.validate_micro(d, True)

    def test_complete_http(self):
        self.assertEqual(len(report.validate_http(http())[0]), 192)

    def test_missing_http(self):
        d = http()
        d['runs'].pop()
        with self.assertRaises(AssertionError):
            report.validate_http(d)

    def test_duplicate_http(self):
        d = http()
        d['runs'].append(d['runs'][0])
        with self.assertRaises(AssertionError):
            report.validate_http(d)

    def test_wrong_order_http(self):
        d = http()
        d['runs'][0]['variant'] = 'B'
        with self.assertRaises(AssertionError):
            report.validate_http(d)

    def test_failed_attempt_is_retained(self):
        d = http()
        failed = dict(d['runs'][0], failure='recorded setup failure')
        d['runs'].append(failed)
        completed, failures = report.validate_http(d)
        self.assertEqual(len(completed), 192)
        self.assertEqual(failures, [failed])
if __name__ == '__main__':
    unittest.main()
