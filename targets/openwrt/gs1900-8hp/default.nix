{ hostCfg, workstationKeys }:
{
  openwrt.${hostCfg.hostname} = {
    _module.args = { inherit hostCfg workstationKeys; };

    imports = [
      ../../../bases/openwrt/switch.nix

      ./hardware-configuration.nix
    ];
  };
}
