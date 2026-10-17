# dnsmasq also answers DNS for LAN clients; the upstream resolvers live in `wan.nix`.
{
  uci.settings.dhcp = {
    dnsmasq = [
      {
        authoritative = true;
        cachesize = 1000;
        domain = "lan";
        domainneeded = true;
        expandhosts = true;
        local = "/lan/";
        localise_queries = true;
        localservice = true;
        readethers = true;
        rebind_localhost = true;
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
