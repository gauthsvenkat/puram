{ hostCfg, workstationKeys }:
{
  openwrt.${hostCfg.hostname} = {
    _module.args = { inherit hostCfg workstationKeys; };

    imports = [
      ../../../bases/openwrt/router.nix

      ./hardware-configuration.nix
    ];
  };
}
