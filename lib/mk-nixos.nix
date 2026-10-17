{
  allTargetCfgs,
  inputs,
  evalNixos,
}:
name:
let
  targetCfg = allTargetCfgs.${name};
  inherit (targetCfg) system;
in
evalNixos {
  inherit system;
  specialArgs = {
    inherit allTargetCfgs targetCfg inputs;
  };
  modules = [ ../targets/nixos/${name} ];
}
