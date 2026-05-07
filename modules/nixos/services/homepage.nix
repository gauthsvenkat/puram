{ hostCfg, config, ... }:
let
  inherit (hostCfg) domain;
  inherit (hostCfg.ports) homepage;
  inherit (config.sops) secrets;
  vhost = "homepage.${domain}";
in
{
  sops.secrets.homepage_env = { };

  services.homepage-dashboard = {
    enable = true;
    listenPort = homepage.port;
    allowedHosts = vhost;
    environmentFiles = [ secrets.homepage_env.path ];
  };

  services.caddy.virtualHosts.${vhost}.extraConfig = ''
    reverse_proxy 127.0.0.1:${toString homepage.port}
  '';
}
