{ openwrtCfg, ... }:
let
  inherit (openwrtCfg) country;
in
{
  uci.settings.wireless.wifi-device = {
    radio0 = {
      band = "2g";
      channel = 1;
      inherit country;
      htmode = "HE20";
      path = "platform/soc/18000000.wifi";
      type = "mac80211";
    };

    radio1 = {
      band = "5g";
      channel = 36;
      inherit country;
      htmode = "HE80";
      path = "platform/soc/18000000.wifi+1";
      type = "mac80211";
    };
  };
}
