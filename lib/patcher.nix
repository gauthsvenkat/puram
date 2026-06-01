{
  nixpkgs,
  patches ? [ ],
}:
{
  system,
  specialArgs,
  modules,
}:
let
  pkgs = import nixpkgs { inherit system; };
  src = pkgs.applyPatches {
    name = "nixpkgs-patched";
    src = nixpkgs;
    patches = map pkgs.fetchpatch2 patches;
  };
in
import "${src}/nixos/lib/eval-config.nix" {
  inherit system specialArgs;
  modules = modules ++ [ { nixpkgs.flake.source = src.outPath; } ];
}
