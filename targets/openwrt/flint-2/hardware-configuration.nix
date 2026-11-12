{ openwrtCfg, ... }:
let
  inherit (openwrtCfg) country;
in
{
  uci.settings.wireless.wifi-device = {
    radio0 = {
      path = "platform/soc/18000000.wifi";
      type = "mac80211";
      band = "2g";
      channel = 1;
      inherit country;
      htmode = "HE20";
    };

    radio1 = {
      path = "platform/soc/18000000.wifi+1";
      type = "mac80211";
      band = "5g";
      channel = 36;
      inherit country;
      htmode = "HE80";
    };
  };
}
