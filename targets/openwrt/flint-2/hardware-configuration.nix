{
  uci.settings.wireless.wifi-device = {
    radio0 = {
      band = "2g";
      channel = 1;
      country = "NL";
      htmode = "HE20";
      path = "platform/soc/18000000.wifi";
      type = "mac80211";
    };

    radio1 = {
      band = "5g";
      channel = 36;
      country = "NL";
      htmode = "HE80";
      path = "platform/soc/18000000.wifi+1";
      type = "mac80211";
    };
  };
}
