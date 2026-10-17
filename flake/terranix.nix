{ allTargetCfgs, inputs }:
let
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  inherit (pkgs) lib;

  mkTerranix =
    name:
    let
      targetCfg = allTargetCfgs.${name};
    in
    inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      extraArgs = { inherit allTargetCfgs targetCfg; };
      modules = [ ../targets/terranix/${name} ];
    };

  infraConfig = mkTerranix "infra";

  # map :: (provider -> String) -> [ provider ] -> [ String ]
  #   where provider = { source :: String; version :: String }
  # :: [ String ], nixpkgs attribute name of each required provider, "owner_name"
  providerNames = map (provider: lib.replaceStrings [ "/" ] [ "_" ] provider.source) (
    lib.attrValues infraConfig.config.terraform.required_providers
  );
  tofu = pkgs.opentofu.withPlugins (lib.attrVals providerNames);
in
{
  packages."x86_64-linux".infra-config = infraConfig;

  devShells."x86_64-linux".default = pkgs.mkShell {
    packages = [
      tofu
      pkgs.sops
    ];
  };
}
