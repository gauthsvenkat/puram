# Patches

Diffs applied to the `nixpkgs` source at evaluation time, used as a holding pen
for upstream PRs that haven't merged yet but that this repo needs.

## How it works

`default.nix` in this directory exposes `mkNixos`. It picks up every `*.patch`
file in this directory via `builtins.readDir`, runs them through `pkgs.applyPatches`,
and evaluates each NixOS configuration against the patched source so both
modules and `pkgs` reflect the patches. If the directory contains no patches, it
short-circuits to vanilla nixpkgs and does nothing. Darwin hosts skip this path
entirely.

## Adding a patch

```sh
gh pr diff <PR_NUMBER> --repo NixOS/nixpkgs \
  > patches/<topic>-<PR_NUMBER>.patch
```

`git add` the file (flakes ignore untracked files) and run `just check` to
confirm it applies cleanly against the locked nixpkgs. No edits to `flake.nix`
are needed — the file is auto-discovered.

## Removing a patch

When the upstream PR merges and `nixpkgs` is bumped past it, delete the
`.patch` file.

## Conventions

- One file per upstream PR.
- Keep the patch byte-identical to `gh pr diff` output so re-fetching is
  trivial. Add context at the top of the file as comment lines (lines before
  the first `diff --git` are ignored by `patch`).
