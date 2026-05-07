{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    domain
    images
    paths
    ;
  inherit (hostCfg.ports.prowlarr) port;
in
{
  virtualisation.oci-containers.containers.prowlarr = {
    image = images.prowlarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [ "${paths.config}/prowlarr:/config" ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };

  services.caddy.virtualHosts."prowlarr.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
