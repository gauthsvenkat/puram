{
  hostCfg,
  ...
}:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = hostCfg.ports.immich.port;
    mediaLocation = "${hostCfg.paths.data}/immich";
    openFirewall = true;
  };

  services.caddy.virtualHosts."immich.${hostCfg.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString hostCfg.ports.immich.port}
  '';
}
