# Context

The layout is in [README.md](./README.md); how-to guides are in [`how-to/`](./how-to/).

- `targets/<platform>/<hostname>/` holds `default.nix` and `targetCfg.nix`, plus `hardware-configuration.nix` (generated), `disko-config.nix` or `bootstrap.nix` where the platform needs them.
- Composition: target imports bases, bases import modules, e.g. `niri.nix` -> `workstation.nix` -> `system.nix`. Modules MUST NOT import other modules; a module that doesn't apply to every host is split into files in its own subdirectory.
- One `nixpkgs` input (`nixos-unstable`); every input that takes `nixpkgs` follows it.

# Workflow

- `just --list --list-submodules` shows all recipes; plain `--list` hides the platform modules.
- Check that the flake evaluates with `just check`. It skips the OpenWrt images; see the HACK in [`justfile`](./justfile).

# Conventions

Before changing any file, read [CONVENTIONS.md](./CONVENTIONS.md) and follow it.

Don't add comments, except type comments. When reviewing comments I wrote, flag the ones that break the conventions.
