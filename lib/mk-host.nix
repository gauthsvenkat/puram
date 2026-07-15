{ inputs, mkNixos }:
name: system:
let
  builder =
    if inputs.nixpkgs.lib.hasSuffix "darwin" system then
      inputs.nix-darwin.lib.darwinSystem
    else
      mkNixos;
in
builder {
  inherit system;
  specialArgs = {
    inherit inputs;
    hostCfg = import ../hosts/${name}/hostCfg.nix;
  };
  modules = [ ../hosts/${name} ];
}
