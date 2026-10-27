{
  openwrtCfg,
  targetCfg,
  workstationKeys,
  ...
}:
{
  openwrt.${targetCfg.hostname} = {
    _module.args = { inherit openwrtCfg targetCfg workstationKeys; };

    imports = [
      ../../../bases/openwrt/switch.nix

      ./hardware-configuration.nix
    ];
  };
}
