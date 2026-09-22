{
  allHostCfgs,
  inputs,
  evalNixos,
}:
name: system:
evalNixos {
  inherit system;
  specialArgs = {
    inherit allHostCfgs inputs;
    hostCfg = allHostCfgs.${name};
  };
  modules = [ ../hosts/${name} ];
}
