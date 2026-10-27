{
  allTargetCfgs,
  flakeCfg,
  openwrtCfg,
  targetCfg,
}:
{
  openwrt.${targetCfg.hostname} = {
    _module.args = {
      inherit
        allTargetCfgs
        flakeCfg
        openwrtCfg
        targetCfg
        ;
    };

    imports = [
      ../../../bases/openwrt/router.nix

      ./hardware-configuration.nix
    ];
  };
}
