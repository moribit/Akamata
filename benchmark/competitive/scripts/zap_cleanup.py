#!/usr/bin/env python3
"""Reclaim pinned facil.io request spill files after the owning server exits.

Never run during a measured interval. Do not modify the competitor binary or
replace its real file-backed request path with an in-memory shortcut.
"""
import argparse
import json
import os
import stat
from pathlib import Path


def cleanup(directory, since, until):
    from native_evidence import query
    return query("zap-cleanup", arguments=(directory, since, until))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--directory", default="/private/var/tmp")
    parser.add_argument("--since", type=float, required=True)
    parser.add_argument("--until", type=float, required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    result = cleanup(args.directory, args.since, args.until)
    Path(args.output).write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
