{ hostCfg, lib, ... }:
let
  inherit (hostCfg) radios;
in
{
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
