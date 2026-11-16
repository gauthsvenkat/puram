{ targetCfg, config, ... }:
let
  inherit (targetCfg) ports;
  inherit (config.services.headscale) user;
  inherit (config.sops) secrets;
in
{
  sops.secrets."headscale/headplane_cookie_secret" = {
    sopsFile = ../../../secrets/headscale.yaml;
    key = "headplane_cookie_secret";
    owner = user;
    restartUnits = [ "headplane.service" ];
  };

  services.headplane = {
    enable = true;
    settings.server = {
      cookie_secret_path = secrets."headscale/headplane_cookie_secret".path;
      port = ports.headplane;
    };
  };

  systemd.services.headplane.wantedBy = [ "headscale.service" ];
}
