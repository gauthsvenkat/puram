rec {
  hostname = "elitedesk";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";

  zpool = "dontdie";
  domain = "example.com";
  paths = rec {
    config = "/${zpool}/services/config";
    databases = "/${zpool}/services/databases";
    postgres = "${databases}/postgres";
    data = "/${zpool}/data";
    cache = "/${zpool}/cache";
  };

  ports = {
    adguard = {
      dns_port = 53;
      web_port = 3000;
    };
    # Cosmetic - Caddy hardcodes its admin API on 127.0.0.1:2019.
    # Tracked here for documentation.
    caddy.admin_port = 2019;
    homepage.port = 7575;
    immich.port = 2283;
    # Cosmetic - services.jellyfin hardcodes 8096/8920 TCP and 1900/7359 UDP via
    # openFirewall. Tracked here for documentation.
    jellyfin = {
      port = 8096;
      https_port = 8920;
    };
    paperless = {
      port = 8000;
      gotenberg_port = 3030;
      tika_port = 9998;
    };
  };
}
