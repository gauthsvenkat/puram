# Returns a function that builds a NixOS config with every patch listed below
# fetched and applied to nixpkgs. Short-circuits to vanilla nixpkgs when the
# list is empty (and for darwin hosts, which don't call this entry point).
{ nixpkgs }:
# Inner function called per-host in flake.nix.
{
  system,
  specialArgs,
  modules,
}:
let
  pkgs = import nixpkgs { inherit system; };
  patches = map pkgs.fetchpatch2 [
    {
      name = "jellyfin-hevc10bit-520045";
      url = "https://github.com/NixOS/nixpkgs/pull/520045.patch?full_index=1";
      hash = "sha256-fmAG7AcagzUEfBEzkJ8cSG5prX/TgAth3s1JhHEzTzU=";
    }
  ];
  src =
    if patches == [ ] then
      nixpkgs
    else
      pkgs.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        inherit patches;
      };
in
# eval-config.nix from the patched src so NixOS modules see the patches too;
# nixpkgs.flake.source pins pkgs to the same patched tree.
import "${src}/nixos/lib/eval-config.nix" {
  inherit system specialArgs;
  modules = modules ++ [ { nixpkgs.flake.source = src.outPath; } ];
}
