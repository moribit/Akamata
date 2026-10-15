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
    if until < since:
        raise ValueError("invalid cleanup ownership window")
    report = {"directory": str(directory), "since": since, "until": until,
              "removed_files": 0, "removed_allocated_bytes": 0, "preserved_files": 0}
    directory_fd = os.open(directory, os.O_RDONLY | os.O_DIRECTORY | os.O_CLOEXEC)
    try:
        with os.scandir(directory_fd) as entries:
            for entry in entries:
                if not entry.name.startswith("facil_io_tmpfile_"):
                    continue
                fd = None
                try:
                    fd = os.open(entry.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
                                 dir_fd=directory_fd)
                    info = os.fstat(fd)
                    # Only this benchmark's x-filled request payloads, owned by
                    # this uid and created within the stopped server's lifetime.
                    if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid()
                            or info.st_nlink != 1 or not 0 < info.st_size <= 65536
                            or not since <= info.st_mtime <= until):
                        report["preserved_files"] += 1
                        continue
                    with os.fdopen(fd, "rb") as source:
                        fd = None
                        data = source.read(65537)
                    if data != b"x" * info.st_size:
                        report["preserved_files"] += 1
                        continue
                    current = os.stat(entry.name, dir_fd=directory_fd, follow_symlinks=False)
                    if (current.st_dev, current.st_ino, current.st_mtime_ns, current.st_size) != (
                            info.st_dev, info.st_ino, info.st_mtime_ns, info.st_size):
                        report["preserved_files"] += 1
                        continue
                    os.unlink(entry.name, dir_fd=directory_fd)
                    report["removed_files"] += 1
                    report["removed_allocated_bytes"] += info.st_blocks * 512
                except (FileNotFoundError, IsADirectoryError):
                    report["preserved_files"] += 1
                except OSError:
                    # Symlinks must never be followed or deleted.
                    if entry.is_symlink():
                        report["preserved_files"] += 1
                    else:
                        raise
                finally:
                    if fd is not None:
                        os.close(fd)
    finally:
        os.close(directory_fd)
    return report


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
