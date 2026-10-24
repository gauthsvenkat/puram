{ targetCfg, workstationKeys, ... }:
{
  openwrt.${targetCfg.hostname} = {
    _module.args = { inherit targetCfg workstationKeys; };

    imports = [
      ../../../bases/openwrt/switch.nix

      ./hardware-configuration.nix
    ];
  };
}
