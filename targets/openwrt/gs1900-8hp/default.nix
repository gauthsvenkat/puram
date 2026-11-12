{
  flakeCfg,
  openwrtCfg,
  targetCfg,
  ...
}:
let
  inherit (targetCfg) hostname;
in
{
  openwrt.${hostname} = {
    _module.args = { inherit flakeCfg openwrtCfg targetCfg; };

    imports = [
      ../../../bases/openwrt/switch.nix

      ./hardware-configuration.nix
    ];
  };
}
