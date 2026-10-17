{ allTargetCfgs, inputs }:
name:
let
  targetCfg = allTargetCfgs.${name};
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
in
inputs.terranix.lib.terranixConfiguration {
  inherit pkgs;
  extraArgs = { inherit allTargetCfgs targetCfg; };
  modules = [ ../targets/terranix/${name} ];
}
