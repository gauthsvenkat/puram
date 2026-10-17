{ targetCfg, lib, ... }:
let
  inherit (targetCfg) radios switch;
in
{
  uci.settings = {
    network = {
      switch = [
        {
          inherit (switch) name;
          reset = true;
          enable_vlan = true;
        }
      ];

      # imap1 :: (index::Int -> vlan -> switchVlan) -> [ vlan ] -> [ switchVlan ]
      #   where vlan = { vid :: Int; ports :: String }
      #         switchVlan = vlan // { device :: String; vlan :: Int }
      switch_vlan = lib.imap1 (
        i:
        { vid, ports }:
        {
          device = switch.name;
          vlan = i;
          inherit vid ports;
        }
      ) switch.vlans;
    };

    # mapAttrs :: (radioName::String -> radio -> wifiDevice) -> { radioName::String -> radio } -> { radioName::String -> wifiDevice }
    #   where radio = { path, band, htmode :: String; channel :: Int }
    #         wifiDevice = radio // { type, country :: String }
    wireless.wifi-device = lib.mapAttrs (_: radio: {
      type = "mac80211";
      country = "NL";
      inherit (radio)
        band
        channel
        htmode
        path
        ;
    }) radios;

    system.led = {
      led_wan = {
        name = "WAN";
        sysfs = "green:wan";
        trigger = "switch0";
        port_mask = "0x02";
      };
      led_lan1 = {
        name = "LAN1";
        sysfs = "green:lan1";
        trigger = "switch0";
        port_mask = "0x04";
      };
      led_lan2 = {
        name = "LAN2";
        sysfs = "green:lan2";
        trigger = "switch0";
        port_mask = "0x08";
      };
      led_lan3 = {
        name = "LAN3";
        sysfs = "green:lan3";
        trigger = "switch0";
        port_mask = "0x10";
      };
      led_lan4 = {
        name = "LAN4";
        sysfs = "green:lan4";
        trigger = "switch0";
        port_mask = "0x20";
      };
    };
  };
}
