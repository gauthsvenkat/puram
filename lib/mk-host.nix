{ inputs, mkNixos }:
name: system:
mkNixos {
  inherit system;
  specialArgs = {
    inherit inputs;
    hostCfg = import ../hosts/${name}/hostCfg.nix;
  };
  modules = [ ../hosts/${name} ];
}
