{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    domain
    images
    paths
    ;
  inherit (hostCfg.ports.sonarr) port;
in
{
  virtualisation.oci-containers.containers.sonarr = {
    image = images.sonarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [
      "${paths.config}/sonarr:/config"
      "${paths.data}/entertainment:/data"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };

  services.caddy.virtualHosts."sonarr.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
