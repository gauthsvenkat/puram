{ targetCfg, lib, ... }:
let
  inherit (targetCfg) lan;
  inherit (targetCfg.ports) adguard;
in
{
  packages = [ "adguardhome" ];

  etc."adguardhome/adguardhome.yaml".text = lib.toJSON {
    dns = {
      anonymize_client_ip = true;
      bind_hosts = [ "127.0.0.1" ];
      port = adguard.dns_port;
      upstream_mode = "load_balance";
      refuse_any = true;
      use_private_ptr_resolvers = false;
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
    };

    filters = [
      {
        id = 1;
        name = "AdGuard DNS filter";
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
        enabled = true;
      }
      {
        id = 8;
        name = "NoCoin Filter List";
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
        enabled = true;
      }
      {
        id = 11;
        name = "Malicious URL Blocklist (URLHaus)";
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
        enabled = true;
      }
      {
        id = 27;
        name = "OISD Blocklist Big";
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
        enabled = true;
      }
      {
        id = 31;
        name = "Stalkerware Indicators List";
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt";
        enabled = true;
      }
    ];

    http.address = "${lan.ip}:${toString adguard.web_port}";

    querylog = {
      enabled = true;
      file_enabled = false;
      size_memory = 1024;
    };

    schema_version = 34;

    statistics.enabled = true;
  };

  uci.settings.adguardhome.adguardhome.config = {
    config_file = "/etc/adguardhome/adguardhome.yaml";
    group = "adguardhome";
    user = "adguardhome";
    work_dir = "/var/lib/adguardhome";
  };
}
