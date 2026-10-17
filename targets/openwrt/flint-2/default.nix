{ targetCfg, workstationKeys }:
{
  openwrt.${targetCfg.hostname} = {
    _module.args = { inherit targetCfg workstationKeys; };

    imports = [
      ../../../bases/openwrt/router.nix

      ./hardware-configuration.nix
    ];
  };
}
