{ targetCfg, lib, ... }:
let
  inherit (targetCfg) radios;
in
{
  # mapAttrs :: (radioName::String -> radio -> wifiDevice) -> { radioName::String -> radio } -> { radioName::String -> wifiDevice }
  #   where radio = { path, band, htmode :: String; channel :: Int }
  #         wifiDevice = radio // { type, country :: String }
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
