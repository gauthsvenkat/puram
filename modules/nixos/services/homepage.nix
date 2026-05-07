{ hostCfg, config, ... }:
let
  inherit (hostCfg) domain;
  inherit (hostCfg.ports) homepage;
  inherit (config.sops) secrets;
in
{
  sops.secrets.homepage_env = { };

  services.homepage-dashboard = {
    enable = true;
    listenPort = homepage.port;
    allowedHosts = "homepage.${domain}";
    environmentFiles = [ secrets.homepage_env.path ];
  };
}
