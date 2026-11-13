{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) ports;
in
{
  packages = [ "https-dns-proxy" ];

  uci.settings.https-dns-proxy = {
    https-dns-proxy = [
      {
        bootstrap_dns = "9.9.9.9,1.1.1.1";
        listen_port = ports.doh;
        resolver_url = "https://${fqdns.dns}/dns-query";
      }
    ];

    # `dnsmasq_config_update` swaps the plain-IP upstreams in `dnsmasq.nix` for the proxy,
    # and `force_dns` redirects LAN DNS on port 53 to dnsmasq and rejects DoT on port 853.
    # Both are on by default; turning them off keeps the upstreams and the firewall rules in Nix.
    # https://docs.mossdef.org/https-dns-proxy/#dnsmasq_config_update
    main.config = {
      dnsmasq_config_update = "-";
      force_dns = false;
    };
  };
}
