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
}
