# Storage listing ownership and pagination

Use `Store.listPage(allocator, prefix, cursor, limit)` for new code. A `ListPage` owns an operation arena backed by the supplied allocator. All entries, keys, etags, content types, custom JSON and continuation tokens belong to the page until `page.deinit()`. Store mutation, another listing and Store destruction do not invalidate them. Do not copy the owning page, free individual slices or retain slices after deinit. Allocation failure releases the entire operation arena, including adapter parsing allocations.

Limits are 1–1000 entries; prefixes use portable relative object key syntax. Empty/NUL-containing/over-4096-byte cursors are rejected. Continuation tokens are opaque and must be passed to the same store with the same prefix. Native tokens currently encode the last lexical key; R2 tokens come from the host. Tokens are not portable between providers, do not establish a snapshot, and must not be constructed by applications. A malformed backend token may return BackendFailure when the host does not expose a distinct invalid-cursor error. `cursor == null` is the end condition; a short page alone is not the end condition. Listing during mutation is not a transactional snapshot.

Filesystem, MemoryStore and R2 use the same owned page facade. Filesystem listing returns size and modification time; optional metadata availability is provider-specific. MemoryStore snapshots its borrowed metadata. R2 requests HTTP/custom metadata and preserves the host cursor, including short non-final pages. The private Workers page ABI is additive: update managed glue when building an application using listPage. Old binaries retain their existing list ABI.

## Compatibility

The existing `list()` signature and custom Store VTable initializers remain source compatible. It is a legacy adapter-specific ownership API: keys/entries are caller allocated; metadata lifetime depends on the adapter; R2 requires an operation arena. Existing callers are not silently switched to a different cleanup convention. Migrate to listPage and replace manual key/slice frees with page.deinit(). No removal date is set yet.

Custom lexical adapters can keep their existing list callback. The facade requests one extra entry to determine continuation, and snapshots all metadata. Non-lexical adapters must provide the optional VTable.list_page callback; its PageData allocations use the provided operation allocator. No adapter may retain that allocator or PageData after the operation. R2 supplies this callback rather than treating an opaque host cursor as a key.

## Evidence

`zig build portable-application-test` executes shared pagination against MemoryStore and Filesystem and checks every Native page allocation failure using the testing allocator. `zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe -j4` runs the same contract through WASM R2 host simulation. Managed JS bridge tests additionally verify the actual template/root glue returns host continuation and metadata and closes host list handles. These are offline adapter contracts, not live Cloudflare evidence.

Host reference: https://developers.cloudflare.com/r2/api/workers/workers-api-reference/
