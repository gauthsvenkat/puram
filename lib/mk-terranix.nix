{ allHostCfgs, inputs }:
name:
let
  hostCfg = allHostCfgs.${name};
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
in
inputs.terranix.lib.terranixConfiguration {
  inherit pkgs;
  extraArgs = { inherit allHostCfgs hostCfg; };
  modules = [ ../targets/terranix/${name} ];
}
