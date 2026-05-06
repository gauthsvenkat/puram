{ hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images paths;
  port = hostCfg.ports.bazarr.port;
in
{
  virtualisation.oci-containers.containers.bazarr = {
    image = images.bazarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [
      "${paths.config}/bazarr:/config"
      "${paths.data}/entertainment:/data"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };

  services.caddy.virtualHosts."bazarr.${hostCfg.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
