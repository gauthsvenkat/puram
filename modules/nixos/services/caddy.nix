{
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.caddy;
  inherit (config) sops;
in
{
  sops = {
    secrets."dns/cloudflare_dns_token" = {
      sopsFile = ../../../secrets/dns.yaml;
      key = "cloudflare_dns_token";
    };

    templates."caddy_env" = {
      content = "CLOUDFLARE_API_TOKEN=${sops.placeholder."dns/cloudflare_dns_token"}\n";
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

  systemd.services.caddy.serviceConfig.EnvironmentFile = sops.templates."caddy_env".path;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
