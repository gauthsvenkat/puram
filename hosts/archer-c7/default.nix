{ hostCfg, workstationKeys }:
{
  openwrt.${hostCfg.hostname} = {
    _module.args = { inherit hostCfg workstationKeys; };

    imports = [
      ../../bases/router.nix

      ./hardware-configuration.nix
    ];
  };
}
