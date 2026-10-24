{
  allTargetCfgs,
  inputs,
  openwrtTargets,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  inherit (pkgs) lib;

  # catAttrs :: attrName::String -> [ targetCfg ] -> [ sshUserKey::String ]
  # :: [ sshUserKey::String ], one per host that has one
  workstationKeys = lib.catAttrs "sshUserKey" (lib.attrValues allTargetCfgs);

  mkOpenwrt =
    name:
    let
      targetCfg = allTargetCfgs.${name};
    in
    {
      image = inputs.openwrt-imagebuilder.lib.build {
        inherit pkgs;
        inherit (targetCfg)
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
          configuration = import ../targets/openwrt/${name} {
            inherit allTargetCfgs targetCfg workstationKeys;
          };
        }).targets.${name};
    };
in
{
  # mergeAttrsList :: [ { packageName::String -> Derivation } ] -> { packageName::String -> Derivation }
  # :: { packageName::String -> Derivation }, keyed "${hostname}-openwrt-image" and "${hostname}-deploy"
  packages."x86_64-linux" = lib.mergeAttrsList (
    map (
      name:
      let
        router = mkOpenwrt name;
      in
      {
        "${name}-openwrt-image" = router.image;
        "${name}-deploy" = router.deploy;
      }
    ) openwrtTargets
  );
}
