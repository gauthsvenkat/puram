{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    images
    paths
    ;
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
}
