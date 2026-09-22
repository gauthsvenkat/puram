{ hostCfg, lib, ... }:
let
  inherit (hostCfg) radios switch;
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
