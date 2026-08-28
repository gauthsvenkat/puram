{
  allHostCfgs,
  inputs,
  mkNixos,
}:
name: system:
mkNixos {
  inherit system;
  specialArgs = {
    inherit allHostCfgs inputs;
    hostCfg = allHostCfgs.${name};
  };
  modules = [ ../hosts/${name} ];
}
