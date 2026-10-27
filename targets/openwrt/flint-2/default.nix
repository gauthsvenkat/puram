{
  flakeCfg,
  openwrtCfg,
  targetCfg,
  targetCfgs,
}:
{
  openwrt.${targetCfg.hostname} = {
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
