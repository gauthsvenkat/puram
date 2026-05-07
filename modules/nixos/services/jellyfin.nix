{ hostCfg, ... }:
let
  inherit (hostCfg) domain paths;
  inherit (hostCfg.ports.jellyfin) port;
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    configDir = "${paths.config}/jellyfin";
    dataDir = "${paths.databases}/jellyfin";
    cacheDir = "${paths.cache}/jellyfin";
  };

  services.caddy.virtualHosts."jellyfin.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
