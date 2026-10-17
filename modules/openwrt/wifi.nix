{ targetCfg, lib, ... }:
let
  inherit (targetCfg) radios;
in
{
  # mapAttrs' :: (radioName::String -> radio -> { name :: String; value :: iface }) -> { radioName::String -> radio } -> { ifaceName::String -> iface }
  #   where radio = { path, band, htmode :: String; channel :: Int }
  #         iface = { device, mode, network, encryption :: String; ssid, key :: secret }
  # :: { ifaceName::String -> iface }, keyed "default_${radioName}"
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
