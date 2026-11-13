{ targetCfg, config, ... }:
let
  inherit (targetCfg) ports;
  inherit (config.services.headscale) user;
  inherit (config.sops) secrets;
in
{
  sops.secrets."headplane_cookie_secret" = {
    owner = user;
    sopsFile = ../../../secrets/headscale.yaml;
  };

  services.headplane = {
    enable = true;
    settings.server = {
      cookie_secret_path = secrets."headplane_cookie_secret".path;
      port = ports.headplane;
    };
  };
}
