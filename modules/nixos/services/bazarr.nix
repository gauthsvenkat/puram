{ hostCfg, ... }:
let
  inherit (hostCfg) paths;
  inherit (hostCfg.ports.bazarr) port;
in
{
  services.bazarr = {
    enable = true;
    dataDir = "${paths.config}/bazarr";
    listenPort = port;
  };
}
