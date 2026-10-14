# Workers comparison and evidence boundary

Hono 4.13.13 is pinned by `benchmark/competitive/workers/package-lock.json`.
Akamata uses Zig 0.17.0 and the existing typed application, HTTP parser,
Response Cursor and Workers ABI. The new private fixture performs real D1
adapter calls against a **fake synchronous host**, not an invented native path.

```sh
zig build competitive-worker-build -Dbackend=workers -Doptimize=ReleaseSafe
npm ci --prefix benchmark/competitive/workers --ignore-scripts
node benchmark/competitive/workers/wasm-host.mjs zig-out/bin/competitive-worker.wasm workers-host.json
```

[Recorded host evidence](raw/workers-host.json) verifies exact expected bodies,
HTTP statuses and Content-Type for plaintext, JSON, parameter routing, D1 row
conversion and 64 B/1 KiB/64 KiB echo, against Hono's same workloads. Statement
handles are reclaimed after every request; the explicit test teardown closes
the isolate-owned App and DB. Unexpected host effects fail the test.

The artifact hash, size, Node version, command and local module compilation,
initialization and first-request wall times are recorded. These timings are
**not Cloudflare CPU time, edge latency or cold-start measurements**. They
include local JS/WASM host work and a fake D1; JSPI suspension and remote query
execution are not exercised. They are not used to claim superiority over Hono.

No dedicated test Workers/D1 deployment was established for this initiative;
no live resources are provisioned automatically. Live comparison remains
unexecuted until dedicated isolated resources and authorization are available.
It must use the same account/environment, HTTP/1.1 payloads, SQL/dataset and
load generator, preserving errors, with cleanup limited to those test resources.
Record CPU/wall via the actual Workers observability surface, not these host
timestamps. No production readiness or Cloudflare performance claim follows
from this successful simulation.
