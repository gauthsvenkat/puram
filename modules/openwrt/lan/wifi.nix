{
  uci.settings.wireless.wifi-iface =
    let
      ap = {
        mode = "ap";
        network = "lan";
        ssid._secret = "wifi/home_wifi_ssid";
        encryption = "sae-mixed";
        key._secret = "wifi/home_wifi_psk";
      };
    in
    {
      default_radio0 = ap // {
        device = "radio0";
      };
      default_radio1 = ap // {
        device = "radio1";
      };
    };
}
