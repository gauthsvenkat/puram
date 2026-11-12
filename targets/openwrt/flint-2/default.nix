{
  flakeCfg,
  openwrtCfg,
  targetCfg,

  targetCfgs,
}:
let
  inherit (targetCfg) hostname;
in
{
  openwrt.${hostname} = {
    _module.args = {
      inherit
        flakeCfg
        openwrtCfg
        targetCfg

        targetCfgs
        ;
    };

    imports = [
      ../../../bases/openwrt/router.nix

      ./hardware-configuration.nix
    ];
  };
}
