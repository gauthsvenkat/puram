{ hostCfg, ... }:
let
  inherit (hostCfg.ports) adguard;
in
{
  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    port = adguard.web_port;
    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = adguard.dns_port;
        upstream_mode = "parallel";
        refuse_any = true;
        upstream_dns = [
          "https://dns10.quad9.net/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://security.cloudflare-dns.com/dns-query"
          "https://adblock.doh.mullvad.net/dns-query"
          "https://dns.nextdns.io"
        ];
        bootstrap_dns = [
          "9.9.9.10"
          "149.112.112.10"
          "2620:fe::10"
          "2620:fe::fe:10"
        ];
        fallback_dns = [
          "https://anycast.dns.nextdns.io"
          "https://dns.google/dns-query"
          "https://dns.cloudflare.com/dns-query"
        ];
      };

      filters = [
        {
          id = 1;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          enabled = true;
        }
        {
          id = 2;
          name = "AdAway Default Blocklist";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          enabled = true;
        }
        {
          id = 1715284080;
          name = "OISD Blocklist Big";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
          enabled = true;
        }
        {
          id = 1715284081;
          name = "Steven Black's List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
          enabled = true;
        }
      ];
    };
  };
  # DNS ports needs explicit allow in firewall
  networking.firewall.allowedTCPPorts = [ adguard.dns_port ];
  networking.firewall.allowedUDPPorts = [ adguard.dns_port ];
}
