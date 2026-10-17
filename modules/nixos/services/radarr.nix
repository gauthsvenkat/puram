{ targetCfg, ... }:
let
  inherit (targetCfg) paths;
  inherit (targetCfg.ports.radarr) port;
in
{
  services.radarr = {
    enable = true;
    dataDir = "${paths.config}/radarr";
    settings.server.port = port;
  };
}
