{
  nixpkgs,
  # :: [ { url, hash :: String } ], each passed to fetchpatch2
  patches ? [ ],
}:
{
  system,
  specialArgs,
  modules,
}:
let
  pkgs = import nixpkgs { inherit system; };
  src =
    if patches == [ ] then
      nixpkgs
    else
      pkgs.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = map pkgs.fetchpatch2 patches;
      };
in
import "${src}/nixos/lib/eval-config.nix" {
  inherit system specialArgs;
  modules = modules ++ [ { nixpkgs.flake.source = src.outPath; } ];
}
