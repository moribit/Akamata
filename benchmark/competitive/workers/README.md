# Workers comparison

Hono 4.13.13, package-lock pinned. `npm ci && npm test` checks host wire behavior
with a fake D1 binding; it does not measure Cloudflare CPU, deployment cold start
or edge network latency. It must not be ranked against Native server throughput.
The text Content-Type is explicitly aligned with Akamata; body bytes remain exact.

Live runs require dedicated **test** Workers and D1 resources, both implementations
in the same account/environment, same SQL/data, explicit resource isolation and
cleanup. This fixture never creates resources merely because it needs DB. The
Native Zig u64 path range is wider than JavaScript's safe integer range; normal
benchmark IDs are exactly representable on both platforms.
