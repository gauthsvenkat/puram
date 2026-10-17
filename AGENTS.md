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
  nixos/<hostname>/    -- default.nix + targetCfg.nix + hardware-configuration.nix (+ disko-config.nix if applicable)
  openwrt/<hostname>/  -- default.nix + targetCfg.nix + bootstrap.nix + hardware-configuration.nix
  terranix/infra/      -- default.nix + targetCfg.nix; not a machine, renders config.tf.json for `just tf`
flake/            -- flake outputs split by platform (nixos, openwrt, terranix), merged in flake.nix
docs/             -- operational notes (setup-*, server-*, repo-*)
assets/           -- non-nix assets (configs/, wallpapers/)
secrets/          -- sops-nix encrypted secrets, split by scope (system, homeserver, infra), plus the tofu-encrypted terraform.tfstate; .sops.yaml is the access matrix
justfile          -- task runner: flake-wide recipes, plus one module per platform in recipes/*.just
```

# Key concepts

- `targetCfg` -- attribute set passed via `specialArgs`, defined per-host as a literal `rec { ... }` in `targets/<platform>/<hostname>/targetCfg.nix`. Bases and modules read from this instead of hardcoding paths/ports/image tags/env defaults. Flows to home-manager via `extraSpecialArgs`.
- Single `nixpkgs` input (`nixos-unstable`); `home-manager`, `sops-nix`, `disko`, `plasma-manager`, and `niri` all follow it.
- Base composition chain: host imports bases, bases import modules. E.g., `kde.nix` -> `personal.nix` -> `workstation.nix` -> `system.nix`.

# Architecture

- Modules MUST NOT import other modules. They are self-contained building blocks for reuse across bases and hosts.
- If a module's configuration doesn't apply to all hosts, split it into multiple files within its own subdirectory so bases/hosts can selectively import.

# Workflow

- Apply: `just nixos apply` (or `just a`). Defaults to `switch`, accepts action arg (e.g., `just a test`)
- Check: `just check-fast` (or `just c`) -- runs `nix flake check`
- Update inputs: `just update` -- optionally pass a single input name
- Upgrade: `just upgrade` -- updates flake lock, runs check-full, and commits; apply separately
- Deploy: `just nixos deploy <hostname>` -- builds locally, deploys to remote host
- Infra: `just terranix tf <args>` (or `just tf`) -- renders the terranix config and runs opentofu on it (plan, apply, ...)
- Secrets: `just secrets edit|view|rekey`
- OpenWrt: `just openwrt build|deploy`

# Code style

- Use kebab-case for filenames (e.g., `graphics-drivers.nix`)
- Prefer `lib.*` over `builtins.*` whenever lib re-exports the function (it re-exports most of builtins); `builtins.*` only when lib has no counterpart
- Name bindings so the shape is obvious. Split pipelines with surprising intermediate types into named bindings
- A binding built with a collection-shaping `lib` function (`mapAttrs`, `filterAttrs`, `listToAttrs`, `imap1`, `catAttrs`, `concatMapAttrs`, `readDir`, `map`, ...) gets a type comment block above it: the function's signature as used here, a `where` line expanding every name in it, then, only when there is something the signature cannot say (a filter, a key pattern, a constraint), the binding's own type after `# ::` followed by that clause. Omit the `# ::` line when it would only repeat the return type. Primitives are `String`, `Int`, `Bool`, `Path`, `Derivation`; `[ T ]` is a list; `{ k1, k2 :: T }` a set with fixed keys; `{ String -> T }` a set keyed by arbitrary names; `a -> b` a function. Only `targetCfg` and `secret` (a dewclaw `{ _secret :: String }`) stay unexpanded. Example:
  ```nix
  # imap1 :: (id::Int -> name::String -> port) -> [ name::String ] -> [ port ]
  #   where port = { id :: Int; name :: String; enable :: Bool }
  port = lib.imap1 (id: name: { inherit id name; enable = true; }) poe.ports;

  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with an sshHostKey
  serverCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? sshHostKey) allTargetCfgs;
  ```
- A primitive carries a role label, `role::Type`, whenever the value means something the type alone does not say: `hostname::String`, `orgId::String`, `port::Int`. The label is lowerCamel like a binding name. Use it instead of a trailing clause explaining a primitive and instead of a bare role name; never label a non-primitive, those have a `where` line. Fixed keys in a `where` line keep the spaced form `id :: Int`; the unspaced `role::Type` is only for labels. Keep the same label for the same value along a pipeline so it can be followed: `readDir :: Path -> { hostname::String -> fileType::String }`, then `attrNames :: ... -> [ hostname::String ]`. A primitive with no role beyond its type stays bare: `Bool`, `Derivation`.
- Collapse single-definition attribute sets using dot notation (e.g., `services.openssh.enable = true;`)
- Group multiple definitions with common prefixes into a single attribute set
- Sort lexicographically: package lists, imports, attribute definitions within groups
- Use `lib.getExe`/`lib.getExe'` instead of `"${pkg}/bin/name"` interpolation
- Quote user-chosen attribute names, both where defined and where referenced: `sops.secrets."wifi_psk"`, `placeholder."wifi_psk"`, `allTargetCfgs."elitedesk"`, terraform instance names, disko devices, own systemd units. Leave bare: `targetCfg` keys, upstream or schema names (`systemd.services.postgresql`, uci `lan`/`wan`/`loopback`), and `${}` names.

## Comments

Don't add comments (type comments excepted). These rules are for reviewing the ones I write:

- Flag comments that only repeat the code.
- Tags: `TODO:` work left to do, `HACK:` workaround for an upstream problem (remove when fixed), `NOTE:` warning to read before changing the code.
- Backtick code references: options, attributes, systemd directives, env vars, paths, commands, file modes. Write literal values as the code does (`` `"pppoe"` ``). Product and package names stay plain.
- Write option paths as they read in the enclosing block (`zfs.forceImportRoot` inside `boot = { ... }`).

## let / inherit

- Top-level `let` is reserved for bindings that depend on `targetCfg` or `config`. Other helpers go in the lowest scope where they're used (often inside an attribute value).
- Never inline `targetCfg.<field>` or `config.<field>` in module bodies. Pull them into the top-level `let` so the module's surface area is visible upfront. Exception: a field used once, by a bare `inherit`, is inherited at the call site instead (`inherit (targetCfg.ports.jellyfin) port;`).
- Top-level `let` order, top to bottom: `inherit (targetCfg) ...;`, `cfg = config.services.X;` (or `cfg_<name>` when more than one), `inherit (config.sops) secrets;`, then derived bindings (`vhost`, `dataRoot`, ...). Example:
  ```nix
  let
    inherit (targetCfg) domain paths;
    inherit (targetCfg.ports) paperless;
    cfg = config.services.paperless;
    inherit (config.sops) secrets;
    vhost = "paperless.${domain}";
  in
  ```
- Prefer `inherit (source) field;` over `field = source.field;` when the names match (statix W04). Apply at every scope, including inside attribute sets.
- Bare `inherit foo bar;` is only for re-exporting names already bound in the enclosing scope.
- Inline `lib.getExe pkg` at the call site rather than `inherit (lib) getExe;` unless `getExe` is used 2+ times in the file.
- `with` is allowed only inside package list literals (`with pkgs; [ ... ]`). Never `with lib;` or `with config;`.
- `rec { ... }` is reserved for `targetCfg` definitions in `targets/<platform>/<hostname>/targetCfg.nix`. Don't introduce `rec` elsewhere.
- Function arguments use destructuring with `...`. Don't use `@args`.
- If a module body uses no arguments at all, omit the function head entirely - write a bare attrset, not `{ ... }: { ... }`.
- Auto-generated `targets/nixos/*/hardware-configuration.nix` files are exempt - let `nixos-generate-config` own them.
