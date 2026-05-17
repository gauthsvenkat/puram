# Patches

Diffs applied to the `nixpkgs` source at evaluation time, used as a holding pen
for upstream PRs that haven't merged yet but that this repo needs.

## How it works

`flake.nix` defines `patchedNixpkgsFor system` and `mkNixos`:

- `patchedNixpkgsFor` calls `pkgs.applyPatches` with every file listed in the
  `patches = [ ... ]` array, producing a patched nixpkgs source in the store.
- `mkNixos` evaluates each NixOS configuration via the patched tree's
  `nixos/lib/eval-config.nix`, so both NixOS modules and `pkgs` reflect the
  patches. Darwin hosts skip this path — they evaluate against vanilla nixpkgs.

## Adding a patch

```sh
gh pr diff <PR_NUMBER> --repo NixOS/nixpkgs \
  > patches/<topic>-<PR_NUMBER>.patch
```

Then append the file to the `patches = [ ... ]` list in `flake.nix` and stage
it with git (`git add` — flakes ignore untracked files). Run `just check` to
confirm it applies cleanly against the locked nixpkgs.

## Removing a patch

When the upstream PR merges and `nixpkgs` is bumped past it:

1. Delete the `.patch` file.
2. Remove its entry from the `patches = [ ... ]` list in `flake.nix`.
3. If the list is now empty, the `mkNixos` helper can be deleted entirely and
   call sites reverted to `nixpkgs.lib.nixosSystem`.

## Conventions

- One file per upstream PR. Name as `<topic>-<PR_NUMBER>.patch`.
- Keep the patch byte-identical to `gh pr diff` output so re-fetching is
  trivial. Add context at the top of the file as comment lines (lines before
  the first `diff --git` are ignored by `patch`).
