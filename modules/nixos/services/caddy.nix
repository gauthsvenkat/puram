{
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.caddy;
  inherit (config.sops) placeholder templates;
in
{
  sops = {
    secrets."cloudflare_dns_token" = { };

    templates."cloudflare_env" = {
      content = "CLOUDFLARE_API_TOKEN=${placeholder."cloudflare_dns_token"}\n";
      inherit (cfg) group;
      owner = cfg.user;
      restartUnits = [ "caddy.service" ];
    };
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

  systemd.services.caddy.serviceConfig.EnvironmentFile = templates."cloudflare_env".path;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
