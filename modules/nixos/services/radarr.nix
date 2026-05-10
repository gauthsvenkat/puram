{ hostCfg, ... }:
let
  inherit (hostCfg) paths;
  inherit (hostCfg.ports.radarr) port;
in
{
  services.radarr = {
    enable = true;
    dataDir = "${paths.config}/radarr";
    settings.server.port = port;
  };
}
