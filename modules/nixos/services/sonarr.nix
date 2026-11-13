{ targetCfg, ... }:
let
  inherit (targetCfg) paths ports;
in
{
  services.sonarr = {
    enable = true;
    dataDir = "${paths.config}/sonarr";
    settings.server.port = ports.sonarr;
  };
}
