# Structure

```
modules/          -- self-contained, reusable modules (MUST NOT import other modules)
  common/         -- shared between nixos and darwin (home-manager, sops, nix-settings)
  nixos/          -- NixOS-specific (system/, hardware/, services/, gui/, extra/)
  darwin/         -- macOS-specific (system/, gui/, services/, homebrew)
  home-manager/   -- platform-agnostic user config (development/, terminal/, extra/)
bases/            -- composable configs that import modules
  common/         -- cross-platform bases (system.nix, workstation.nix)
  nixos/          -- NixOS bases (system.nix, workstation.nix, flavor/, desktop-environment/)
  darwin/         -- macOS bases (system.nix, workstation.nix)
hosts/            -- per-machine configs that import bases + host-specific modules
  <hostname>/     -- default.nix + hardware-configuration.nix (+ disko-config.nix if applicable)
secrets.yaml      -- sops-nix encrypted secrets (age keys derived from SSH keys)
justfile          -- task runner for common operations
```

# Key concepts

- `hostCfg` -- attribute set passed via `specialArgs` containing: `hostname`, `username`, `isLaptop`, `homeDirectory`, `gitEmail`, `wallpaper`. Defined per-host in `flake.nix` via `mkHostCfg`. Flows to home-manager via `extraSpecialArgs`.
- Separate nixpkgs/home-manager/sops-nix inputs for NixOS vs darwin (e.g., `nixpkgs-nixos`, `nixpkgs-darwin`).
- Base composition chain: host imports bases, bases import modules. E.g., `kde.nix` -> `personal.nix` -> `workstation.nix` -> `system.nix`.

# Architecture

- Modules MUST NOT import other modules. They are self-contained building blocks for reuse across bases and hosts.
- If a module's configuration doesn't apply to all hosts, split it into multiple files within its own subdirectory so bases/hosts can selectively import.

# Workflow

- Apply: `just apply` (or `just a`). Defaults to `switch`, accepts action arg (e.g., `just apply test`)
- Check: `just check` (or `just c`) -- runs `nix flake check`
- Update inputs: `just update` (or `just u`) -- optionally pass a single input name
- Upgrade: `just upgrade` -- updates flake lock, rebuilds, and commits
- Deploy: `just deploy <hostname>` -- builds locally, deploys to remote host
- Secrets: `just secrets-edit`, `just secrets-view`, `just secrets-rekey`

# Code style

- Use kebab-case for filenames (e.g., `graphics-drivers.nix`)
- Collapse single-definition attribute sets using dot notation (e.g., `services.openssh.enable = true;`)
- Group multiple definitions with common prefixes into a single attribute set
- Sort lexicographically: package lists, imports, attribute definitions within groups
- Use `lib.getExe`/`lib.getExe'` instead of `"${pkg}/bin/name"` interpolation
