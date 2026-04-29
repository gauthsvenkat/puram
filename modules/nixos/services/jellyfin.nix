{ hostCfg, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    configDir = "${hostCfg.paths.config}/jellyfin";
    dataDir = "${hostCfg.paths.databases}/jellyfin";
    cacheDir = "${hostCfg.paths.cache}/jellyfin";
  };
}
