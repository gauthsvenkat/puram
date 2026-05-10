{ hostCfg, ... }:
let
  inherit (hostCfg) paths;
  inherit (hostCfg.ports.sonarr) port;
in
{
  services.sonarr = {
    enable = true;
    dataDir = "${paths.config}/sonarr";
    settings.server.port = port;
  };
}
