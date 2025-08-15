{
  networking.firewall =
    let
      dns_port = 53;
    in
    {
      allowedTCPPorts = [ dns_port ];
      allowedUDPPorts = [ dns_port ];
    };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      # users = [
      #   {
      #     name = "<some-username>";
      #     password = "<hashed-password-here>";
      #   }
      # ];

      dns = {
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
        upstream_mode = "parallel";
      };

      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
          name = "OISD Blocklist Big";
          id = 1715284080;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
          name = "Steven Black's List";
          id = 1715284081;
        }
      ];
    };
  };
}
