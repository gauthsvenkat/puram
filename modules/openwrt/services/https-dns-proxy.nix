{ flakeCfg, ... }:
let
  inherit (flakeCfg) domain;
in
{
  packages = [ "https-dns-proxy" ];

  uci.settings.https-dns-proxy = {
    https-dns-proxy = [
      {
        bootstrap_dns = "9.9.9.9,1.1.1.1";
        listen_port = 5053;
        resolver_url = "https://dns.${domain}/dns-query";
      }
    ];

    # `dnsmasq.nix` sets the forwarding and the firewall stays declarative,
    # so `dnsmasq_config_update` and `force_dns` are off.
    main.config = {
      dnsmasq_config_update = "-";
      force_dns = false;
    };
  };
}
