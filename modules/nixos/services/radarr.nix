{ targetCfg, ... }:
let
  inherit (targetCfg) paths ports;
in
{
  services.radarr = {
    enable = true;
    dataDir = "${paths.config}/radarr";
    settings.server.port = ports.radarr;
  };
}
