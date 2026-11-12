#!/usr/bin/env python3
"""Report every measured round; do not discard errors or combine percentiles."""
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
    from native_evidence import query
    print(f"Evidence: \x60{args.input}\x60.")
    print(query("summarize", data, raw=True), end="")



if __name__ == "__main__":
    main()
