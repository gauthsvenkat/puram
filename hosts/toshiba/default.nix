{
  hostCfg,
  lib,
  ...
}:
let
  inherit (hostCfg) domain paths zpool;
  inherit (hostCfg.ports) adguard immich;

  proxy = p: ''
    reverse_proxy 127.0.0.1:${toString p}
  '';
in
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../modules/common/tailscale.nix

    ../../modules/nixos/services/adguard-home.nix
    ../../modules/nixos/services/caddy.nix
    ../../modules/nixos/services/immich.nix
    ../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/sanoid.nix
    ../../modules/nixos/services/zfs.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      # NOTE: This system is so old systemd doesn't work. We use grub instead.
      systemd-boot.enable = lib.mkForce false;
      grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
      };
    };
    zfs.extraPools = [ zpool ];
  };

  # AdGuard Home runs with `DynamicUser=true`, which makes systemd redirect
  # its StateDirectory to /var/lib/private/<name>. Bind the actual path.
  fileSystems."/var/lib/private/AdGuardHome" = {
    device = "${paths.config}/adguard-home";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/${zpool}" ];
  };

  services = {
    caddy.virtualHosts = {
      "immich.${domain}".extraConfig = proxy immich.port;
      "adguard.${domain}".extraConfig = proxy adguard.web_port;
    };

    logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

    sanoid.datasets."${zpool}" = {
      recursive = true;
      process_children_only = true;
      use_template = [ "default" ];
    };
  };
}
