{ hostCfg, ... }:
let
  inherit (hostCfg) paths;
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    configDir = "${paths.config}/jellyfin";
    dataDir = "${paths.databases}/jellyfin";
    cacheDir = "${paths.cache}/jellyfin";
  };
}
