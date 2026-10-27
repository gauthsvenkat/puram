{
  inputs,
  flakeCfg,
  targetCfgs,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
  inherit (pkgs) lib;

  openwrtCfg = {
    # KPN accepts any credentials; `internet` is their documented placeholder.
    pppoe = {
      username = "internet";
      password = "internet";
      vid = 6;
    };
    country = "NL";
    # The router's address on the network the switch is on.
    gateway = targetCfgs.openwrt.${flakeCfg.router}.homelab.ip;
    release = "25.12.5";
    timezone = "CET-1CEST,M3.5.0,M10.5.0/3";
    zonename = flakeCfg.timezone;
  };

  mkOpenwrt =
    name:
    let
      targetCfg = targetCfgs.openwrt.${name};
    in
    {
      image = inputs.openwrt-imagebuilder.lib.build (
        targetCfg.image
        // {
          inherit pkgs;
          inherit (openwrtCfg) release;
          files = import ../targets/openwrt/${name}/bootstrap.nix {
            inherit
              flakeCfg
              openwrtCfg
              targetCfg

              pkgs
              ;
          };
          packages = [
            "luci"
            "luci-ssl"
          ];
        }
      );

      deploy =
        (import inputs.dewclaw {
          inherit pkgs;
          configuration = import ../targets/openwrt/${name} {
            inherit
              flakeCfg
              openwrtCfg
              targetCfg

              targetCfgs
              ;
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
        networkDevice = mkOpenwrt name;
      in
      {
        "${name}-openwrt-image" = networkDevice.image;
        "${name}-deploy" = networkDevice.deploy;
      }
    ) (lib.attrNames targetCfgs.openwrt)
  );
}
