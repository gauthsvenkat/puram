{
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.caddy;
in
{
  sops.secrets.cloudflare_dns_token = {
    owner = cfg.user;
    group = cfg.group;
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-J0HWjCPoOoARAxDpG2bS9c0x5Wv4Q23qWZbTjd8nW84=";
    };
    email = "gauthsvenkat@gmail.com";
    globalConfig = ''
      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile =
    config.sops.secrets.cloudflare_dns_token.path;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
