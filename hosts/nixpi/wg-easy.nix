{
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets = {
    ".env".file = ./.env;
  };

  /*
    NOTE:
    wg-easy run on a podman backend. For some reason, the docker
    backend crashes on start with cause it doesn't recognize
    "NET_ADMIN" capability.
  */
  virtualisation.oci-containers.containers = {
    "wg-easy" = {
      image = "ghcr.io/wg-easy/wg-easy";
      volumes = [ "wg-easy:/etc/wireguard" ];
      environmentFiles = [ config.age.secrets.".env".path ];
      ports = [
        "51820:51820/udp"
        "51821:51821/tcp"
      ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
        "--cap-add=NET_RAW"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv4.ip_forward=1"
      ];
    };
  };
}
