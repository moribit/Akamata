# Approval-gated migration guide

**Status update:** release/deployment approval was received and the code-only rollout is completed. This guide retains the approval-gated procedure; see [actual results](publication-and-rollout.md).

No command in this document authorizes a formal release or production rollout.

## After explicit release approval

1. Verify fixed candidate 2714af0 and its CI/TSan evidence, clean tree, version and
   draft release notes. Create only a new annotated/signed v0.2.1 tag; never change
   an existing tag. Publish a GitHub Release only after its separate explicit approval.
2. Resolve the real immutable tag archive with `zig fetch`; use its actual package
   hash in all four Consumers. Do not guess a hash or pin floating main.
3. Use the matching candidate/release CLI by absolute path, not an arbitrary PATH
   executable. The scaffold bootstrap pin is separate; update it only in the
   documented post-tag follow-up to avoid a self-referential archive hash.
4. Promote reviewed Consumer fixes: Ehagaki 8ba1655 + 3889b75; Mo-Bus c389a8e +
   dd8273b. Preserve original unrelated files and tracked build-output policy.
5. Run `akamata sync --dry-run` and inspect each diff. Yaku currently has a Git-SHA
   URL and must first receive the real tag pin. Custom news glue is intentionally
   unowned: do not force-replace its image proxy/upload behavior. Preserve gateway,
   binding names and app-owned entrypoints. No generated bridge was hand-edited.
6. Repeat test/build/Workers and relevant staging acceptance on the final pinned
   application SHAs. Regenerate/type-check OpenAPI and clients as needed.

## Schema and secrets

The dependency update changes no application SQL schema. Do not invoke production
migrations merely because deployment scripts offer them. Existing schema behind
current app migrations needs its own diff, consistent backup, isolated rehearsal,
approval and recovery plan. SQLite-to-D1 production switching is separate.

Keep production secrets in their environment. Staging uses freshly generated keys.
Ehagaki requires JWT_SECRET and defaults Workers auto-migration off; the same actual
production signing secret must remain configured for existing Mo-Bus tokens.
Staging success with shared test keys does not verify production key equality.

## Production approval sequence

Yaku → mimoc_news → Ehagaki → mobus-backend, one application at a time. Before each
approval, record pinned app SHA/hash, live version, binding/secret-name checks,
rollback version and exact proposed command. Verify actual HTTP after each rollout.
Use dedicated test records for permitted production writes. Stop on regression.
Worker rollback and DB schema rollback are distinct. Do not roll a production DB
back as a substitute for a Worker code rollback.
