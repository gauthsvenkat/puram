{
  allTargetCfgs,
  openwrtCfg,
  targetCfg,
  workstationKeys,
}:
{
  openwrt.${targetCfg.hostname} = {
    _module.args = {
      inherit
        allTargetCfgs
        openwrtCfg
        targetCfg
        workstationKeys
        ;
    };

    imports = [
      ../../../bases/openwrt/router.nix

      ./hardware-configuration.nix
    ];
  };
}
