# HTTP, routing and JSON cost experiments

[Raw before](raw/micro-before.jsonl), [numeric Writer candidate](raw/micro-numeric-writer.jsonl),
[environment/binary identity](raw/micro-environment.json) and
[candidate identity](raw/micro-numeric-writer-environment.json).
The fixture is `src/competitive_micro.zig`, built with Zig 0.17.0 ReleaseFast
on the Apple M2/macOS host. Five rounds per shape; medians below are nanoseconds
per operation. No network or competitive throughput ranking is inferred.

Commands:

```sh
zig build competitive-micro-build -Doptimize=ReleaseFast -j2
# Wait for all builds/tests to stop before running:
./zig-out/bin/competitive-micro > micro.jsonl 2>&1
```

The first attempt overlapped a Workers build. It is retained as
`raw/micro-overlapped-build-excluded*` and excluded from these results. All
reported cases were rerun serially after the build completed.

## JSON

| Shape | Existing Akamata | std.json | Numeric Writer candidate |
|---|---:|---:|---:|
| small | 26 | 37 | 24 |
| 1 KiB string | 647 | 653 | 655 |
| 64 KiB string | 39,727 | 40,775 | 39,810 |
| nested DTO | 73 | 87 | 74 |
| 512 u64 array | 3,440 | 3,076 | 2,195 |

Serialization uses a fixed output Writer; both implementations' bytes are
compared before timing. Integer/float emission changes only from formatting into
a fixed intermediate buffer to writing the same `{d}` format into the existing
Writer. The integer-array screen improves by approximately 36%; string and
nested differences are small and not claimed as improvements. This does not
establish a 36% HTTP throughput improvement.

The old 24-byte integer and 32-byte float buffers also trap for valid u128 and
finite f64 extremes. [Baseline boundary tests](raw/json-boundary-before.json)
reproduce `NoSpaceLeft` panics. New unit tests round-trip u128 maximum, i128
minimum, 1e308 and 1e-308. Ordinary formats and ownership remain unchanged;
no borrowed response or extra allocation is introduced.

Deserialization already delegates to `std.json`. Measured wrapper medians are
78 ns small, 1,117 ns medium, 67,047 ns large, 242 ns nested and 12,572 ns array.
It would be misleading to claim an independent Akamata decoder advantage.

## Parser

Retained-arena parsing: small request 166 ns; eight-header POST with framing,
query and a three-byte body 783 ns. Header/target validation and smuggling
checks remain intact. No SIMD or alternate parser was added without an
end-to-end measured benefit. Allocation attribution remains in the separate
existing `http-allocation-profile` fixture; these timings are uninstrumented.

## Route matcher

| Routes | Literal | Parameter | Wildcard |
|---:|---:|---:|---:|
| 10 | 47 | 47 | 35 |
| 100 | 955 | 980 | 919 |
| 1,000 | 9,918 | 10,442 | 8,580 |

This is **direct Graph.match plus runtime path formatting**, alternating first,
middle, last and missing paths. It excludes middleware, handler dispatch and
prepared App indices. In particular the ordinary App's prepared literal-route
index must not be described as a 1,000-route linear scan based on this table.
The existing bounded specialization threshold is retained; an unmeasured trie
rewrite would introduce compile-size/ownership complexity for a different path.
Use `examples/router_bench` for full App/middleware network scaling.

The existing router runner's oha decoding has been updated from the obsolete
`metrics.*` JSON shape to oha 1.15's response-count/total and latencyPercentiles
fields, and artifact sizing is portable across macOS/Linux. Its default counts
now include 10/100/1000. This short diagnostic runner is not the requested
competitive 10/30-second five-round matrix; its results must not be relabeled.
