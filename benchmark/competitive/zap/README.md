# zap fixture

Upstream release v0.11.0, peeled commit
`66c5dc42c781bbb8a9100afda3c7e69ee96eddf3` (its internal package version says
0.10.6). Upstream pins Zig 0.15.1; this fixture uses the installed patch 0.15.2.
Akamata remains Zig 0.17.0. No private port of zap to a newer compiler is ranked.

After building the common SQLite archive, run
`python3 benchmark/competitive/scripts/build_zap.py` on this macOS host. The old
upstream build runner cannot link against the macOS 27 default SDK. This helper
mirrors upstream C files/flags without modifying source, and explicitly links
the existing macOS 15.4 SDK with Zig 0.15.2. On a supported host the standard
`cd benchmark/competitive/zap && zig build -Doptimize=ReleaseFast` remains available.
Binary: `zig-out/bin/competitive-zap`. Eight threads, one process, no logging,
1 MiB body limit, 60-second idle timeout, same explicit Content-Type/body.

The upstream built-in Router is exact-path only: parameter-route extraction
here is manual, as in upstream route examples. It is separately labeled, not a
generic-routing superiority comparison. DB uses the common benchmark C owner.
