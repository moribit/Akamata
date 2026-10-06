# Releasing Akamata

This guide describes the lightweight release process for maintainers.

## Versioning

Akamata uses `vMAJOR.MINOR.PATCH` tags and follows Semantic Versioning with the usual 0.x flexibility:

- `0.0.x`: bug fixes and small compatible improvements.
- `0.x.0`: larger features or API changes.
- `1.0.0`: stable public API commitment.

The version source of truth is `build.zig.zon`; keep the CLI version constant, scaffold metadata, CHANGELOG, and release notes synchronized with it.

## Checklist

1. Update `main`, inspect existing tags, and confirm the working tree contains only intended changes.
2. Update `build.zig.zon`, `tools/akamata/src/release.zig`, help/version references,
   README and CHANGELOG. Keep the scaffold on the previous immutable tag until
   the new tag hash exists, and explain that temporary bootstrap pin.
3. Run the release gates:

   ```bash
   zig build test
   zig build cli
   zig build scaffold-test
   zig build scaffold-local-test public-journey-test documentation-test -Doptimize=ReleaseSafe
   zig build documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
   zig build -Dexample=chat
   zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSmall
   ```

   Full CI and Linux/macOS TSan must be green before tagging. For presentation
   changes, regenerate both PDFs, inspect every page, run the PDF/link contract
   and record benchmark environment/commit/binary hash. Offline Workers fixtures
   do not authorize a live production certification claim.

4. Run CLI checks: `akamata --version`, `akamata help`, `akamata deploy --help`, and `akamata migrate --help`.
5. Commit the release preparation changes.
6. Create an annotated tag:

   ```bash
   git tag -a vX.Y.Z -m "Akamata vX.Y.Z"
   git push origin main
   git push origin vX.Y.Z
   ```

7. Create a non-draft, non-prerelease GitHub Release titled `Akamata vX.Y.Z`, using the corresponding CHANGELOG section.
8. After the tag exists, fetch its archive with Zig and verify the content hash:

   ```bash
   zig fetch https://github.com/moribit/Akamata/archive/refs/tags/vX.Y.Z.tar.gz
   ```

9. Update the scaffold dependency to the stable tag and exact hash in a follow-up commit. This avoids a self-referential archive: a release archive cannot contain its own final archive hash. For the initial v0.0.1 release, the scaffold is pinned to the immutable release-preparation revision; subsequent releases should pin to the previous stable release.
10. In a directory unrelated to the checkout, run `akamata init release-smoke --target=both`, then `zig build`, the Workers build, and `akamata migrate up`.

## Tag conventions

Use annotated tags named exactly `vMAJOR.MINOR.PATCH`, for example `v0.0.1` and `v0.0.2`. Never force-update a published tag. If a release mistake is found, publish a new patch version.

## Release artifacts and support

GitHub Releases are the public release record. No package registry, Homebrew formula, or container registry is implied by this process. The current `main` and current release line are supported until a later policy is published.
