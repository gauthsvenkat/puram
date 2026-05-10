{ hostCfg, ... }:
let
  inherit (hostCfg) paths;
  inherit (hostCfg.ports.prowlarr) port;
in
{
  services.prowlarr = {
    enable = true;
    dataDir = "${paths.config}/prowlarr";
    settings.server.port = port;
  };
}
