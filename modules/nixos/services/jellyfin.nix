{ hostCfg, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    configDir = "${hostCfg.paths.config}/jellyfin";
    dataDir = "${hostCfg.paths.databases}/jellyfin";
    cacheDir = "${hostCfg.paths.cache}/jellyfin";
  };

  services.caddy.virtualHosts."jellyfin.${hostCfg.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString hostCfg.ports.jellyfin.port}
  '';
}
