# Competitive performance fixtures

This directory is benchmark infrastructure, not an application tutorial or a
new production runtime. Native fixtures share HTTP/1.1 bodies, Content-Type,
payload limit and keep-alive policy. Dedicated runtime entrypoints cannot enable
Reactor through public App.serve. Dependencies here are benchmark-only.

The architecture baseline and every future command/result live in
[`benchmark-results/competitive`](../../benchmark-results/competitive/architecture-baseline.md).
Results without matching workload semantics are not ranked together. A short
development smoke measurement must never be relabeled as the required five
30-second rounds with ten-second warmup.
