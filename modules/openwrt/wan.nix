{ hostCfg, ... }:
let
  inherit (hostCfg) wan;
in
{
  uci.settings = {
    # KPN accepts any credentials; `internet` is their documented placeholder.
    network.interface.wan = {
      inherit (wan) device;
      proto = "pppoe";
      username = "internet";
      password = "internet";
      ipv6 = "auto";
      peerdns = false;
      dns = [
        "9.9.9.9"
        "1.1.1.1"
      ];
    };

    dhcp.dhcp.wan = {
      interface = "wan";
      ignore = true;
    };
  };
}
