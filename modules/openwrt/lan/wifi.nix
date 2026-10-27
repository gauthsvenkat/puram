{
  uci.settings.wireless.wifi-iface =
    let
      ap = {
        mode = "ap";
        network = "lan";
        ssid._secret = "wifi_ssid";
        encryption = "psk2";
        key._secret = "wifi_psk";
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
