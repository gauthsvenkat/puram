{ hostCfg, ... }:
let
  inherit (hostCfg) paths;
in
{
  services.jellyfin = {
    enable = true;
    dataDir = "${paths.config}/jellyfin";
  };
}
