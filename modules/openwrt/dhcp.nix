{ allTargetCfgs, ... }:
let
  elitedesk = allTargetCfgs."elitedesk".lan;
in
{
  uci.settings.dhcp = {
    dnsmasq = [
      {
        authoritative = true;
        cachesize = 1000;
        # dnsmasq answers `.lan` itself and forwards the rest to AdGuard Home on elitedesk.
        domain = "lan";
        domainneeded = true;
        expandhosts = true;
        local = "/lan/";
        localise_queries = true;
        localservice = true;
        noresolv = true;
        readethers = true;
        rebind_localhost = true;
        # The public resolvers only answer if elitedesk is down.
        server = [
          elitedesk.ip
          "9.9.9.9"
          "1.1.1.1"
        ];
        strictorder = true;
      }
    ];

    odhcpd.odhcpd = {
      maindhcp = false;
      leasefile = "/tmp/odhcpd.leases";
      leasetrigger = "/usr/sbin/odhcpd-update";
      loglevel = 4;
      piodir = "/tmp/odhcpd-piodir";
      hostsdir = "/tmp/hosts";
    };
  };
}
