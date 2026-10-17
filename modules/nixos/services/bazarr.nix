{ targetCfg, ... }:
let
  inherit (targetCfg) paths;
  inherit (targetCfg.ports.bazarr) port;
in
{
  services.bazarr = {
    enable = true;
    dataDir = "${paths.config}/bazarr";
    settings.general.port = port;
  };
}
