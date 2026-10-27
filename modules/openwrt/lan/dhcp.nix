{ allTargetCfgs, ... }:
let
  elitedesk = allTargetCfgs."elitedesk".lan;
in
{
  uci.settings = {
    network.interface.lan.ip6assign = 60;

    dhcp.dhcp.lan = {
      interface = "lan";
      start = 100;
      limit = 150;
      leasetime = "12h";
      dhcpv4 = "server";
      dhcpv6 = "server";
      ra = "server";
      ra_slaac = true;
      ra_flags = [
        "managed-config"
        "other-config"
      ];
    };

    # static leases
    dhcp.host = [
      {
        name = "elitedesk";
        inherit (elitedesk) ip mac;
      }
    ];
  };
}
