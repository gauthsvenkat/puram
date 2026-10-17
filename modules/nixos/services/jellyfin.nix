{ targetCfg, ... }:
let
  inherit (targetCfg) paths;
in
{
  services.jellyfin = {
    enable = true;
    dataDir = "${paths.config}/jellyfin";
  };
}
