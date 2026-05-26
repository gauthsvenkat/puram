# Patches

URL-pinned `nixpkgs` PRs applied at evaluation time, used as a holding pen for
upstream PRs that haven't merged yet but that this repo needs.

## How it works

`patches.nix` at the repo root exposes `mkNixos`. It carries an inline list of
PR URLs; each entry is fetched via `pkgs.fetchpatch2`, applied to the locked
`nixpkgs` via `pkgs.applyPatches`, and each NixOS configuration is evaluated
against the patched source so both modules and `pkgs` reflect the patches. If
the list is empty, it short-circuits to vanilla `nixpkgs`. Darwin hosts skip
this path entirely.

## Adding a patch

1. Prefetch the hash. `fetchpatch2` normalizes the patch before hashing, so a
   raw `nix-prefetch-url` gives the wrong value -- use the fetcher-aware
   `nix-prefetch` tool:

   ```sh
   nix run nixpkgs#nix-prefetch -- fetchpatch2 \
     --url 'https://github.com/NixOS/nixpkgs/pull/<PR>.patch?full_index=1'
   ```

   The `?full_index=1` query param forces GitHub to emit full-length commit
   hashes in the diff, which is what `fetchpatch2` expects. Without it you'd
   need the older `fetchpatch`.

2. Append an entry to the list in `patches.nix` with the printed hash:

   ```nix
   {
     name = "<topic>-<PR>";
     url = "https://github.com/NixOS/nixpkgs/pull/<PR>.patch?full_index=1";
     hash = "sha256-...";
   }
   ```

3. `just check` to confirm the patch applies cleanly against the locked
   `nixpkgs`. Commit `patches.nix`.

## Removing a patch

Delete the entry from the list. When the upstream PR merges and `nixpkgs`
is bumped past it, that's the trigger.

## Why hashes, not local patch files

A `.patch` file is itself a content hash (its bytes). Switching to a URL+hash
trades N kilobytes of patch body in git for 64 characters of `sha256-...`,
with the same reproducibility guarantees. The hash also acts as a tripwire:
if upstream force-pushes the PR or adds commits, the build fails on hash
mismatch and you get a chance to review before silently picking up new code.

## Conventions

- One entry per upstream PR.
- `name` follows `<topic>-<PR>` so store paths are self-describing.
