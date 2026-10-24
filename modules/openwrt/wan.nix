{ targetCfg, ... }:
let
  inherit (targetCfg) wan;
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
    };

    dhcp.dhcp.wan = {
      interface = "wan";
      ignore = true;
    };
  };
}
