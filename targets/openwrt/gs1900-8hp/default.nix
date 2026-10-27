{
  flakeCfg,
  openwrtCfg,
  targetCfg,
  ...
}:
{
  openwrt.${targetCfg.hostname} = {
    _module.args = { inherit flakeCfg openwrtCfg targetCfg; };

    imports = [
      ../../../bases/openwrt/switch.nix

      ./hardware-configuration.nix
    ];
  };
}
