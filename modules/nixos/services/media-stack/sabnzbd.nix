{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    domain
    images
    paths
    ;
  inherit (hostCfg.ports.sabnzbd) port;
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

  services.caddy.virtualHosts."sabnzbd.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
