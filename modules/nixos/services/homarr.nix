{ config, hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    domain
    images
    paths
    ;
  inherit (hostCfg.ports.homarr) port;
  inherit (config.sops) secrets;
in
{
  sops.secrets.homarr_secret_encryption_key = { };

  virtualisation.oci-containers.containers.homarr = {
    image = images.homarr;
    ports = [ "${toString port}:7575" ];
    environment = {
      inherit (commonEnvVars) TZ;
    };
    environmentFiles = [ secrets.homarr_secret_encryption_key.path ];
    volumes = [
      # Homarr's docker integration only knows /var/run/docker.sock. Podman
      # exposes a Docker-compatible API on its own socket, so the path alias
      # lets Homarr talk to podman without any homarr-side changes.
      "/run/podman/podman.sock:/var/run/docker.sock"
      "${paths.config}/homarr/appdata:/appdata"
    ];
  };

  services.caddy.virtualHosts."homarr.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';

  networking.firewall.allowedTCPPorts = [ port ];
}
