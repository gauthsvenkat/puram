{ hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images paths;
  port = hostCfg.ports.prowlarr.port;
in
{
  virtualisation.oci-containers.containers.prowlarr = {
    image = images.prowlarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [ "${paths.config}/prowlarr:/config" ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };

  services.caddy.virtualHosts."prowlarr.${hostCfg.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
