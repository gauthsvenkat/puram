{ targetCfg, ... }:
let
  inherit (targetCfg) paths;
  inherit (targetCfg.ports.sonarr) port;
in
{
  services.sonarr = {
    enable = true;
    dataDir = "${paths.config}/sonarr";
    settings.server.port = port;
  };
}
