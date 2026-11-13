{ targetCfg, ... }:
let
  inherit (targetCfg) paths ports;
in
{
  services.bazarr = {
    enable = true;
    dataDir = "${paths.config}/bazarr";
    settings.general.port = ports.bazarr;
  };
}
