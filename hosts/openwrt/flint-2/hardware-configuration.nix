{ hostCfg, lib, ... }:
let
  inherit (hostCfg) radios;
in
{
  uci.settings.wireless.wifi-device = lib.mapAttrs (_: radio: {
    type = "mac80211";
    country = "NL";
    inherit (radio)
      band
      channel
      htmode
      path
      ;
  }) radios;
}
