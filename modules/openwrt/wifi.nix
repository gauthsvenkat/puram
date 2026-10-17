{ targetCfg, lib, ... }:
let
  inherit (targetCfg) radios;
in
{
  # mapAttrs' :: (String -> radio -> { name :: String; value :: iface }) -> { String -> radio } -> { String -> iface }
  #   where radio = { path, band, htmode :: String; channel :: Int }
  #         iface = { device, mode, network, encryption :: String; ssid, key :: secret }
  # :: { String -> iface }, keyed "default_${radioName}"
  uci.settings.wireless.wifi-iface = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "default_${name}" {
      device = name;
      mode = "ap";
      network = "lan";
      ssid._secret = "wifi_ssid";
      encryption = "psk2";
      key._secret = "wifi_psk";
    }
  ) radios;
}
