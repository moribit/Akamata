# Opt-in live provider contract

The provider-live workflow is manual only and uses the protected provider-contract-test environment. Default CI never creates or contacts Cloudflare resources. The runner uses the existing device_messaging reference and creates no Worker/D1/R2/Queue/DO infrastructure. Operators provision and deploy an isolated test environment explicitly, including a Queue consumer and the existing DO handler service. The Worker health marker AKAMATA_CONTRACT_TEST_DEPLOYMENT must equal its dedicated deployment name.

Required variables are AKAMATA_LIVE_BASE_URL, AKAMATA_LIVE_SUBJECT (akamata-contract- prefix), AKAMATA_LIVE_LOGIN_SECRET, AKAMATA_LIVE_RESOURCE_MANIFEST and AKAMATA_LIVE_ISOLATED=1. Set AKAMATA_LIVE_OUTPUT to save JSON evidence. Example resource manifest (replace identity hashes and expiry with actual values):

```json
{
  "deployment": "akamata-contract-run123",
  "host": "akamata-contract-run123.example.workers.dev",
  "source_sha": "40 hexadecimal digits from deployed source",
  "binary_sha": "64 hexadecimal digits from deployed WASM SHA-256",
  "expires_at": "a UTC timestamp less than 24 hours ahead",
  "resources": {
    "worker": "akamata-contract-run123",
    "d1": "akamata-contract-run123-db",
    "r2": "akamata-contract-run123-files",
    "queue": "akamata-contract-run123-events",
    "durable_objects": { "script": "akamata-contract-run123" }
  }
}
```

Names, hashes and resource identity are operator attestations, not remote API proofs. Check the dedicated Wrangler configuration against them before running; never reuse production bindings. Health marker is verified before login or writes. HTTPS host must exactly match the manifest; redirects are disabled. Login credentials never appear in evidence. The expiry guards runner authorization and does not delete Cloudflare resources automatically.

Run `node tests/cloudflare_live.mjs` (or zig build cloudflare-live-test) explicitly. Evidence covers authenticated HTTP, D1 write/read, R2 upload/range, actual typed Queue delivery through a D1 marker, DO WebSocket relay, and public rejection of private control paths. Fetch and WebSocket operations have deadlines and bounded receive buffers.

Finally closes test sockets and deletes exact created record/report IDs and random live/ object keys. Cleanup failure makes the run fail and is recorded. An ambiguous POST network failure before its returned ID is received cannot be fully reconciled by this runner; operators must purge dedicated test resources after the run/expiry. Configure R2 lifecycle expiration for live/ objects, use a dedicated D1 DB and DO namespace and set operational TTL/teardown. Never issue broad deletes against production resources. Queue messages cannot be recalled; the report consumer avoids recreating a delivery marker after its report is deleted.

## Evidence levels

| Level | What it proves | What it does not prove |
|---|---|---|
| Unit | Pure metadata, validation, serialization and ownership | Real adapters or host behavior |
| Adapter Contract | Actual Native adapters / injected actual managed JS | Cloudflare deployment or credentials |
| WASM Host Simulation | Zig private ABI, typed dispatch, handles and memory | Real host implementation or billing/resource configuration |
| Live Provider Contract | One explicitly isolated deployment passes application smoke | Every production deployment, durability over long periods or exactly-once |
| Production Observed | Operational evidence from a separately authorized production environment | Universal guarantees |

The current implementation work did not execute live Cloudflare traffic: no dedicated resource manifest, test deployment attestation or test credentials were supplied. Missing opt-in prerequisites fail with exit 2 before network access. Offline successes must not be labeled reachable/ready or Cloudflare production-certified.
