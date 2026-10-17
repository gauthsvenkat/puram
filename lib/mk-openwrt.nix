{ allTargetCfgs, inputs }:
name:
let
  targetCfg = allTargetCfgs.${name};
  inherit (targetCfg)
    profile
    release
    target
    variant
    ;
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  # catAttrs :: String -> [ targetCfg ] -> [ String ]
  # :: [ String ], one ssh public key per host that has one
  workstationKeys = pkgs.lib.catAttrs "sshUserKey" (pkgs.lib.attrValues allTargetCfgs);
in
{
  image = inputs.openwrt-imagebuilder.lib.build {
    inherit
      pkgs
      profile
      release
      target
      variant
      ;
    disabledServices = targetCfg.disabledServices or [ ];
    files = import ../targets/openwrt/${name}/bootstrap.nix { inherit targetCfg pkgs workstationKeys; };
    packages = [
      "luci"
      "luci-ssl"
    ];
  };

  deploy =
    (import inputs.dewclaw {
      inherit pkgs;
      configuration = import ../targets/openwrt/${name} { inherit targetCfg workstationKeys; };
    }).targets.${name};
}
