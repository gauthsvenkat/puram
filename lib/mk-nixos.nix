{
  allHostCfgs,
  inputs,
  evalNixos,
}:
name:
let
  hostCfg = allHostCfgs.${name};
  inherit (hostCfg) system;
in
evalNixos {
  inherit system;
  specialArgs = {
    inherit allHostCfgs hostCfg inputs;
  };
  modules = [ ../targets/nixos/${name} ];
}
