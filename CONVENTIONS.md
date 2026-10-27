# Conventions

## Code style

Formatting, dead code and statix lints are enforced by the pre-commit hooks.

- kebab-case filenames (e.g., `graphics-drivers.nix`)
- `lib.*` over `builtins.*` whenever lib re-exports the function (it re-exports most of builtins); `builtins.*` only when lib has no counterpart
- Binding names show the value's shape: plural for lists (`providerNames`), `…Cfgs` for sets of targetCfgs (`serverCfgs`), `mk…` for builders (`mkNixos`). Pipelines with surprising intermediate types are split into named bindings
- Dot notation for single-definition attribute sets (e.g., `services.openssh.enable = true;`)
- Multiple definitions with a common prefix grouped into a single attribute set
- Lexicographic order for package lists, imports and attribute definitions within groups
- `lib.getExe`/`lib.getExe'` instead of `"${pkg}/bin/name"` interpolation
- Quoted user-chosen attribute names, both where defined and where referenced: `sops.secrets."wifi_psk"`, `placeholder."wifi_psk"`, `targetCfgs.nixos."elitedesk"`, terraform instance names, disko devices, own systemd units. Leave bare: `targetCfg` keys, platform names (`targetCfgs.nixos`), upstream or schema names (`systemd.services.postgresql`, uci `lan`/`wan`/`loopback`), and `${}` names.

## Type comments

- A binding built with a collection-shaping `lib` function (`mapAttrs`, `filterAttrs`, `listToAttrs`, `imap1`, `catAttrs`, `concatMapAttrs`, `readDir`, `map`, ...) gets a type comment block above it.
- The block: the function's signature as used here, then a `where` line expanding every name in it. Only when there is something the signature cannot say (a filter, a key pattern, a constraint), the binding's own type follows after `# ::` with that clause; no `# ::` line when it would only repeat the return type.
- Notation: primitives are `String`, `Int`, `Bool`, `Path`, `Derivation`; `[ T ]` is a list; `{ k1, k2 :: T }` a set with fixed keys; `{ String -> T }` a set keyed by arbitrary names; `a -> b` a function. Only `targetCfg` and `secret` (a dewclaw `{ _secret :: String }`) stay unexpanded.
- Role labels: a primitive carries `role::Type` whenever the value means something the type alone does not say: `hostname::String`, `orgId::String`, `port::Int`. The label is lowerCamel like a binding name, replaces a trailing clause or a bare role name, and never goes on a non-primitive (those have a `where` line). Fixed keys in a `where` line keep the spaced form `id :: Int`. The same value keeps the same label along a pipeline: `readDir :: Path -> { hostname::String -> fileType::String }`, then `attrNames :: ... -> [ hostname::String ]`. A primitive with no role beyond its type stays bare: `Bool`, `Derivation`.

```nix
# imap1 :: (id::Int -> name::String -> port) -> [ name::String ] -> [ port ]
#   where port = { id :: Int; name :: String; enable :: Bool }
port = lib.imap1 (id: name: { inherit id name; enable = true; }) poe.ports;

# filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
# :: { hostname::String -> targetCfg }, hosts with an sshHostKey
serverCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? sshHostKey) targetCfgs.nixos;
```

## Comments

- No comments that only repeat the code.
- Tags only for actionable items: `TODO:` work left to do, `HACK:` workaround for an upstream problem (remove when fixed), `NOTE:` something significant to know before a related action, e.g. changing the code or running a step. Other comments have no tag.
- Backticks around code references: options, attributes, systemd directives, env vars, paths, commands, file modes. Literal values as the code writes them (`` `"pppoe"` ``). Product and package names stay plain.
- Option paths as they read in the enclosing block (`zfs.forceImportRoot` inside `boot = { ... }`).
- In docs, relative links to other repo files: ``[`.sops.yaml`](../.sops.yaml)`` from `how-to/`, not a bare `.sops.yaml`.

## Cfgs

- Plain attrsets, defined in `flake.nix` (`flakeCfg`), `flake/<platform>.nix` (`<platform>Cfg`) and `targets/<platform>/<hostname>/targetCfg.nix` (`targetCfg`), and passed down as module arguments.
- A value lives in the narrowest Cfg that covers all its readers: one target reads it, `targetCfg`; one platform, `<platform>Cfg`; more than one platform, `flakeCfg`. A new reader on another platform moves it up.
- Facts about one target stay in its `targetCfg`, even when other targets read them through `targetCfgs.<platform>.<hostname>`. Higher Cfgs point at the target by name (`router = "flint-2"`) rather than copy its values.

## let / inherit

- Top-level `let` is reserved for bindings that depend on a Cfg (`flakeCfg`, `<platform>Cfg`, `targetCfg`) or `config`. Other helpers go in the lowest scope where they're used (often inside an attribute value).
- No inline `<any>Cfg.<field>` or `config.<field>` in module bodies; they are pulled into the top-level `let` so the module's surface area is visible upfront. Exception: a field used once, by a bare `inherit`, is inherited at the call site instead (`inherit (targetCfg.ports.jellyfin) port;`).
- Top-level `let` order, top to bottom: `inherit` from the Cfgs, broadest first (`flakeCfg`, `<platform>Cfg`, `targetCfg`), `cfg = config.services.X;` (or `cfg_<name>` when more than one), `inherit (config.sops) secrets;`, then derived bindings (`vhost`, `dataRoot`, ...). Example:
  ```nix
  let
    inherit (flakeCfg) domain;
    inherit (targetCfg) paths;
    inherit (targetCfg.ports) paperless;
    cfg = config.services.paperless;
    inherit (config.sops) secrets;
    vhost = "paperless.${domain}";
  in
  ```
- Bare `inherit foo bar;` is only for re-exporting names already bound in the enclosing scope.
- `lib.getExe pkg` inline at the call site rather than `inherit (lib) getExe;`, unless `getExe` is used 2+ times in the file.
- `with` is allowed only inside package list literals (`with pkgs; [ ... ]`). Never `with lib;` or `with config;`.
- `rec { ... }` only in Cfg definitions (`targetCfg.nix`, `flakeCfg`, `<platform>Cfg`), where fields derive from each other; elsewhere, helpers are `let` bindings.
- Function arguments use destructuring with `...`, no `@args`.
- Function arguments, and the `inherit` lists that pass them on (`specialArgs`, `_module.args`, `extraArgs`), are grouped in this order: `inputs`; the Cfgs, broadest first (`flakeCfg`, `<platform>Cfg`, `targetCfg`); `targetCfgs`; module-system arguments (`config`, `lib`, `pkgs`, ...). A blank line separates the groups, unless every group has a single item.
  ```nix
  {
    inputs,

    flakeCfg,
    nixosCfg,
    targetCfg,

    targetCfgs,

    config,
    lib,
    ...
  }:
  ```
- A module body that uses no arguments is a bare attrset, not `{ ... }: { ... }`.
- Generated files like `hardware-configuration.nix` follow the conventions too, as long as the derivation stays the same.
