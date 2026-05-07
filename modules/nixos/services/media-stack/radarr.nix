{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    domain
    images
    paths
    ;
  inherit (hostCfg.ports.radarr) port;
in
{
  virtualisation.oci-containers.containers.radarr = {
    image = images.radarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [
      "${paths.config}/radarr:/config"
      "${paths.data}/entertainment:/data"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };

  services.caddy.virtualHosts."radarr.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
