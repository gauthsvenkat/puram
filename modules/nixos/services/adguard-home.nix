{ targetCfg, ... }:
let
  inherit (targetCfg.ports) adguard;
in
{
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    mutableSettings = false;
    inherit (adguard) port;
    settings = {
      dns = {
        anonymize_client_ip = true;
        bootstrap_dns = [
          # Quad9
          "9.9.9.9"
          "149.112.112.9"
          "2620:fe::9"
          "2620:fe::fe"
          # Cloudflare
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
          # Google
          "8.8.8.8"
          "8.8.4.4"
          "2001:4860:4860::8888"
          "2001:4860:4860::8844"
        ];
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://cloudflare-dns.com/dns-query"
          "https://dns.mullvad.net/dns-query"
          "https://unfiltered.adguard-dns.com/dns-query"
          "https://freedns.controld.com/p0"
        ];
        fallback_dns = [
          "https://dns.nextdns.io/dns-query"
          "https://wikimedia-dns.org/dns-query"
        ];
        ratelimit = 0;
        refuse_any = true;
        use_private_ptr_resolvers = false;
      };

      filters =
        let
          mkFilter = id: name: {
            inherit id name;
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_${toString id}.txt";
          };
        in
        [
          (mkFilter 1 "AdGuard DNS filter")
          (mkFilter 11 "Malicious URL Blocklist (URLHaus)")
          (mkFilter 31 "Stalkerware Indicators List")
          (mkFilter 44 "HaGeZi's Threat Intelligence Feeds")
          (mkFilter 48 "HaGeZi's Pro Blocklist")
        ];

      querylog = {
        enabled = true;
        file_enabled = false;
        size_memory = 1024;
      };

      statistics.enabled = true;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
