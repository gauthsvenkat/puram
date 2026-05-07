{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) domain paths;
  inherit (hostCfg.ports.immich) port;
in
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    inherit port;
    mediaLocation = "${paths.data}/immich";
    openFirewall = true;
  };

  services.caddy.virtualHosts."immich.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
