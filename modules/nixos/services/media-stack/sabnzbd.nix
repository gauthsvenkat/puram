{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    images
    paths
    ;
in
{
  virtualisation.oci-containers.containers.sabnzbd = {
    image = images.sabnzbd;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [
      "${paths.config}/sabnzbd:/config"
      "${paths.data}/entertainment/usenet:/data/usenet"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };
}
