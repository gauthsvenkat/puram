{ allHostCfgs, inputs }:
name:
let
  hostCfg = allHostCfgs.${name};
  inherit (hostCfg)
    profile
    release
    target
    variant
    ;
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  # :: [ sshUserKey ]
  workstationKeys = pkgs.lib.catAttrs "sshUserKey" (pkgs.lib.attrValues allHostCfgs);
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
    files = import ../hosts/${name}/bootstrap.nix { inherit hostCfg pkgs workstationKeys; };
    packages = [
      "luci"
      "luci-ssl"
    ];
  };

  deploy =
    (import inputs.dewclaw {
      inherit pkgs;
      configuration = import ../hosts/${name} { inherit hostCfg workstationKeys; };
    }).targets.${name};
}
