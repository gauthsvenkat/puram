{
  allTargetCfgs,
  inputs,
  openwrtTargets,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  inherit (pkgs) lib;

  # catAttrs :: String -> [ targetCfg ] -> [ String ]
  # :: [ String ], one ssh public key per host that has one
  workstationKeys = lib.catAttrs "sshUserKey" (lib.attrValues allTargetCfgs);

  mkOpenwrt =
    name:
    let
      targetCfg = allTargetCfgs.${name};
      inherit (targetCfg)
        profile
        release
        target
        variant
        ;
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
    };
in
{
  # mergeAttrsList :: [ { String -> Derivation } ] -> { String -> Derivation }
  # :: { String -> Derivation }, keyed "${hostname}-image" and "${hostname}-deploy"
  packages."x86_64-linux" = lib.mergeAttrsList (
    map (
      name:
      let
        router = mkOpenwrt name;
      in
      {
        "${name}-image" = router.image;
        "${name}-deploy" = router.deploy;
      }
    ) openwrtTargets
  );
}
