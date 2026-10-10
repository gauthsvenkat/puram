{
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.caddy;
  inherit (config.sops) placeholder;
in
{
  sops.secrets.cloudflare_dns_token = { };

  sops.templates.cloudflare_env = {
    restartUnits = [ "caddy.service" ];
    content = "CLOUDFLARE_API_TOKEN=${placeholder.cloudflare_dns_token}\n";
    owner = cfg.user;
    inherit (cfg) group;
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
    };
    email = "gauthsvenkat@gmail.com";
    globalConfig = ''
      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.cloudflare_env.path;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
