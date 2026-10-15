# Pinned zap request spill-file investigation

The matrix reached 499 saved cases, then its 1 GiB disk reserve stopped admission.
Unlike the earlier full-disk failures, the checkpoint and failure status survived.

## Cause

Unmodified zap v0.11.0 (`66c5dc42c781bbb8a9100afda3c7e69ee96eddf3`)
contains facil.io's `http1_on_body_chunk`, which spills larger request bodies to
`fiobj_data_newtmpfile`. Its `fiobj/fio_tmpfile.h` calls `mkstemp` and returns the
descriptor without unlinking the pathname. On this Mac, `P_tmpdir` selects
`/var/tmp`, not Python's per-user temporary directory or `/tmp`.

[Investigation](raw/zap-tempfile-investigation.json) found 781,641 matching files,
51,222,626,304 allocated bytes (about 47.7 GiB), created within the stopped
measurement owner's lifetime. Most contain the complete 65,536-byte x payload;
some contain partial requests. Example payload hashes and timestamp bounds are
recorded. This explains the repeatable storage growth; it is not an Akamata
allocator leak, and previous requests to free general host storage did not solve
the cause.

## Harness correction

The competitor source, compiler, binary, shared library, request path and spill
threshold are unchanged. Its file creation, write and close remain part of the
measured workload. Cleanup runs **after the owning server exits**, outside both
warmup and measured intervals, before the next server starts. It does not run
concurrently with another measurement. No tmpfs/in-memory replacement is used.

`zap_cleanup.py` limits removal to same-user, single-link regular files with the
facil prefix, mtime within the stopped server's lifetime and contents matching
the benchmark's x-filled payload (including partial requests). It rejects
symlinks, unrelated contents, other lifetimes and hardlinks; inode/mtime/size are
checked again before unlink. Cleanup errors stop the runner and retain the case
as a failure. Each row records the reclaimed count/bytes and ownership window.
The one-time recovery has separate [evidence](raw/zap-tempfile-recovery.json).

Previous zap 64 KiB echo rows are retained as `excluded_runs` in the checkpoint,
with their reason, and rerun from the cleaned filesystem. They are not selected
based on throughput or latency. Complete matrix validation still requires all
1260 distinct baseline cases and all five rounds, with every client error shown.

Nine offline reporting/cleanup tests passed, including full and partial payloads,
unrelated files, old files, symlink and hardlink preservation. Future upstream
versions should be evaluated separately; this observation concerns the exact
pinned version and build, not every zap release or platform.
