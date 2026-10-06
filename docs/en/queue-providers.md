# Explicit queue providers

Native: `am.jobs.Provider(Descriptor).create(allocator, db, consumer, options)` allocates a stable owner around the existing jobs.Queue engine. The DB is borrowed and must outlive the owner and all workers. The owner has producer(), worker(), stop() and deinit(). No background thread is created implicitly. Application startup registers its finite work before starting Worker.run or calling Worker.tick. Context receives only the borrowed Producer facade.

The primary provider is descriptor-specific. Additional legacy jobs can register on owner.queue. All handlers for a shared akamata_jobs table must be registered on the same polling engine; independent descriptor owners must not poll the same table, because an unknown job name is a terminal jobs failure. Different events requiring a shared engine should use explicit handlerWithDelivery registration; a multi-protocol owner convenience API remains future work.

Shutdown: stop admission with owner.stop(), stop/join worker callers, then owner.deinit(), then close the borrowed DB. stop() does not interrupt a running CPU-bound handler or foreign blocking call. Job payloads remain persisted. Deinit is not a thread join. Partial create failure destroys the owner and callback registry; it does not close the caller-owned DB. Startup code must use errdefer for earlier DB/storage acquisition.

Workers: `am.platform.workers.QueueOwner(Descriptor).create(allocator, binding, consumer)` owns a copied binding name and typed consumer; producer() borrows that stable owner. The application explicitly forwards its existing setQueueConsumer callback to owner.consume(bytes). No additional global registration is installed. consume accepts the existing managed-glue delivery object (body envelope + Cloudflare message ID/attempt). Application event ID is retained; the transport message ID is only a fallback. Dispatch must stop borrowing the owner before deinit. The host owns actual Queue resources and batch acknowledgement/retry; Akamata does not create resources.

## Delivery semantics

Both paths are at-least-once. Metadata carries event type/version, application event ID, correlation ID, idempotency key and max_attempts. Idempotency metadata is not automatic deduplication or exactly-once. Consumers must make repeated effects safe.

Producer admission bounds payload bytes at 64 KiB and individual metadata identifiers at 256 bytes. Workers additionally has a fixed 1024-byte encoded metadata buffer; an envelope whose escaped metadata exceeds that buffer fails locally. Native persists a JSON envelope in the existing job payload column. Storage/DB/queue effects are not one distributed transaction.

Native deliveries obtain attempt = persisted failures + 1 and max_attempts from the actual job row, overriding enqueue-time values. Existing jobs backoff, lease reclaim, terminal failure retention and cleanup are unchanged. A lease reclaim can repeat the same attempt number: the number counts failed attempts, not every duplicate lease delivery. Application max_attempts controls jobs retry failure accounting.

Workers delivery attempts come from Message.attempts, overriding the body attempt. Application max_attempts is metadata, not an override of Cloudflare consumer retry configuration; configure the deployment consumer max_retries/dead-letter extension explicitly. Managed glue acknowledges successful WASM dispatch and retries errors. QueueOwner does not silently discard messages after an application metadata threshold.

## Offline evidence

The Native application test uses actual SQLite + jobs leases/retries to verify attempt 1 failure, attempt 2 success, stable event/correlation/idempotency/version, stop admission and all owner-create allocation failures. WASM host tests verify the Workers owner decodes the existing host delivery wrapper, preserves application event ID and uses host attempt. Managed glue tests verify producer envelopes. These tests do not establish live Cloudflare delivery semantics.
