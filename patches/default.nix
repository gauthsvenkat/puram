# Returns a function that builds a NixOS config with every *.patch here applied to
# nixpkgs. Short-circuits to vanilla nixpkgs when no patches exist.
{ nixpkgs }:
# Inner function that is called per-host in flake.nix.
{
  system,
  specialArgs,
  modules,
}:
let
  # readDir returns { name = type; }; attrNames + filter is Nix's "glob".
  files = builtins.filter (nixpkgs.lib.hasSuffix ".patch") (
    builtins.attrNames (builtins.readDir ./.)
  );
  src =
    if files == [ ] then
      nixpkgs
    else
      (import nixpkgs { inherit system; }).applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        # map strings -> path values so Nix tracks them as build inputs.
        patches = map (n: ./. + "/${n}") files;
      };
in
# eval-config.nix from the patched src so NixOS modules see the patches too;
# nixpkgs.flake.source pins pkgs to the same patched tree.
import "${src}/nixos/lib/eval-config.nix" {
  inherit system specialArgs;
  modules = modules ++ [ { nixpkgs.flake.source = src.outPath; } ];
}
