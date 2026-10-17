{ targetCfg, lib, ... }:
let
  inherit (targetCfg) radios;
in
{
  # mapAttrs :: (String -> radio -> wifiDevice) -> { String -> radio } -> { String -> wifiDevice }
  #   where radio = { path, band, htmode :: String; channel :: Int }
  #         wifiDevice = radio // { type, country :: String }
  # :: { String -> wifiDevice }, keyed by radio name
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
