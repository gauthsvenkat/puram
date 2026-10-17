# Structure

```
modules/          -- self-contained, reusable modules (MUST NOT import other modules)
  nixos/          -- NixOS system config (system/, hardware/, services/, kde-plasma/, niri/)
  home-manager/   -- user config, flat nix files
  openwrt/        -- dewclaw modules for the router, flat nix files
  terranix/       -- terranix modules for opentofu, one per provider
bases/            -- composable configs that import modules, split by platform
  nixos/          -- system, workstation, laptop, personal, server, raspi, kde, niri
  openwrt/        -- router
  terranix/       -- opentofu
targets/          -- deployable units that import bases + target-specific modules, split by platform
  nixos/<hostname>/    -- default.nix + hostCfg.nix + hardware-configuration.nix (+ disko-config.nix if applicable)
  openwrt/<hostname>/  -- default.nix + hostCfg.nix + bootstrap.nix + hardware-configuration.nix
  terranix/infra/      -- default.nix + hostCfg.nix; not a machine, renders config.tf.json for `just tf`
lib/              -- standalone helper functions, composed in flake.nix (mk-nixos, mk-openwrt, mk-terranix, patcher)
docs/             -- operational notes (setup-*, server-*, repo-*)
assets/           -- non-nix assets (configs/, wallpapers/)
secrets/          -- sops-nix encrypted secrets, split by scope (system, homeserver, infra), plus the tofu-encrypted terraform.tfstate; .sops.yaml is the access matrix
justfile          -- task runner for common operations
```

# Key concepts

- `hostCfg` -- attribute set passed via `specialArgs`, defined per-host as a literal `rec { ... }` in `targets/<platform>/<hostname>/hostCfg.nix`. Bases and modules read from this instead of hardcoding paths/ports/image tags/env defaults. Flows to home-manager via `extraSpecialArgs`.
- Single `nixpkgs` input (`nixos-unstable`); `home-manager`, `sops-nix`, `disko`, `plasma-manager`, and `niri` all follow it.
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
- Infra: `just tf <args>` -- renders the terranix config and runs opentofu on it (plan, apply, ...)

# Code style

- Use kebab-case for filenames (e.g., `graphics-drivers.nix`)
- Prefer `lib.*` over `builtins.*` whenever lib re-exports the function (it re-exports most of builtins); `builtins.*` only when lib has no counterpart
- Name bindings so the shape is obvious. Split pipelines with surprising intermediate types into named bindings
- A binding built with a collection-shaping `lib` function (`mapAttrs`, `filterAttrs`, `listToAttrs`, `imap1`, `catAttrs`, `concatMapAttrs`, `readDir`, `map`, ...) gets a type comment block above it: the function's signature as used here, a `where` line expanding every name in it, then the binding's own type after `# ::`. Primitives are `String`, `Int`, `Bool`, `Path`, `Derivation`; `[ T ]` is a list; `{ k1, k2 :: T }` a set with fixed keys; `{ String -> T }` a set keyed by arbitrary names; `a -> b` a function. Only `hostCfg` and `secret` (a dewclaw `{ _secret :: String }`) stay unexpanded. Example:
  ```nix
  # imap1 :: (Int -> String -> port) -> [ String ] -> [ port ]
  #   where port = { id :: Int; name :: String; enable :: Bool }
  # :: [ port ]
  port = lib.imap1 (id: name: { inherit id name; enable = true; }) poe.ports;
  ```
- Collapse single-definition attribute sets using dot notation (e.g., `services.openssh.enable = true;`)
- Group multiple definitions with common prefixes into a single attribute set
- Sort lexicographically: package lists, imports, attribute definitions within groups
- Use `lib.getExe`/`lib.getExe'` instead of `"${pkg}/bin/name"` interpolation

## let / inherit

- Top-level `let` is reserved for bindings that depend on `hostCfg` or `config`. Other helpers go in the lowest scope where they're used (often inside an attribute value).
- Never inline `hostCfg.<field>` or `config.<field>` in module bodies. Pull them into the top-level `let` so the module's surface area is visible upfront. The body references only bound names.
- Top-level `let` order, top to bottom: `inherit (hostCfg) ...;`, `cfg = config.services.X;` (or `cfg_<name>` when more than one), `inherit (config.sops) secrets;`, then derived bindings (`vhost`, `dataRoot`, ...). Example:
  ```nix
  let
    inherit (hostCfg) domain paths;
    inherit (hostCfg.ports) paperless;
    cfg = config.services.paperless;
    inherit (config.sops) secrets;
    vhost = "paperless.${domain}";
  in
  ```
- Prefer `inherit (source) field;` over `field = source.field;` when the names match (statix W04). Apply at every scope, including inside attribute sets.
- Bare `inherit foo bar;` is only for re-exporting names already bound in the enclosing scope.
- Inline `lib.getExe pkg` at the call site rather than `inherit (lib) getExe;` unless `getExe` is used 2+ times in the file.
- `with` is allowed only inside package list literals (`with pkgs; [ ... ]`). Never `with lib;` or `with config;`.
- `rec { ... }` is reserved for `hostCfg` definitions in `targets/<platform>/<hostname>/hostCfg.nix`. Don't introduce `rec` elsewhere.
- Function arguments use destructuring with `...`. Don't use `@args`.
- If a module body uses no arguments at all, omit the function head entirely - write a bare attrset, not `{ ... }: { ... }`.
- Auto-generated `targets/nixos/*/hardware-configuration.nix` files are exempt - let `nixos-generate-config` own them.
