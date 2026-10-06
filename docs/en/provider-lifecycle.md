# Provider lifecycle and checked acquisition

Contract/Provision remain the source of truth. No universal Provider interface, global service locator or remote resource factory is introduced. Existing owners expose optional checked acquisition:

- db.openForContract(allocator, Contract, url) checks provider and exact D1 binding before opening the existing Db adapter.
- StorageFactory.initForContract(allocator, Contract, options) checks filesystem/R2 selection and derives the R2 binding from Provision. Native directory/Io remain explicit borrowed resources.
- jobs.Provider(Descriptor).createForContract(allocator, Contract, db, consumer, options) selects the existing Native jobs engine.
- Workers QueueOwner(Descriptor).createForContract(allocator, Contract, consumer) derives the Queue binding.
- realtime.Native.initForContract(allocator, Contract) and Workers RealtimeOwner.createForContract(allocator, Contract) select the existing backend owner.

These are additive checked factory methods, not new service abstractions. The original manual APIs remain explicit platform escape hatches. A Context facade cannot prove how a manually supplied Db/Store/Producer/Service was initialized; choose checked factories when that proof is required. Worker binding declarations are validated with binding.validateContract separately from resource acquisition.

## Lifetime

App/application State owns or borrows explicit stable owners. Context never destroys a provider. Db.close, filesystem directory.close, Queue owner.deinit and Realtime owner.deinit happen after request dispatch and workers no longer borrow them. A Store factory owns adapter state, not the Native directory or Workers bucket; its old init(options) borrows the supplied R2 binding name. Checked factory binding names have compile-time Contract lifetime. Queue and Realtime heap owners copy names and remain stable until explicit deinit.

Recommended ordering is acquire DB/directory, initialize storage adapter, initialize realtime registry/owner, create/register Queue provider, then start dispatch/workers. On every successful acquisition install errdefer before the next fallible acquisition. On shutdown stop admission, stop/join Queue worker and HTTP/socket borrowers, then release Queue/Realtime owners, directory and DB. Arbitrary blocking application handlers are cooperative; deinit is not cancellation or a thread join.

Workers isolate initialization must install errdefer Db.close, free copied secret configuration and owner.deinit before registering routes. Set the initialized flag only after registration/dispatch setup succeeds. Host isolate termination does not guarantee an application destructor; local deinit is useful for failed initialization/tests, and must never be interpreted as deletion of remote resources.

## Partial failure evidence

The Native portable-application suite checks every allocation failure through DB acquisition + Store view + Realtime owner + Queue owner. Earlier DB and registry resources are closed when a later acquisition fails. Queue-only allocation failure tests additionally prove a caller-owned DB remains usable; ownership is not accidentally transferred. Filesystem list failure closes its operation walker and directory, and owned pages reclaim their whole arena. WASM fixtures repeat adapter operations and assert host handles return to zero and memory plateaus after warmup.

No ordering can turn DB, Storage, Queue and Realtime effects into a distributed transaction. Resource lifetime correctness and delivery idempotency are separate contracts.
