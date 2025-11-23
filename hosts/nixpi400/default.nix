{ inputs, lib, ... }:
let
  zpool = "tank";
in
{
  imports = [
    "${inputs.nixpkgs-nixos}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    ../../bases/nixos/flavor/server.nix

    ../../modules/nixos/services/immich.nix
    ../../modules/nixos/services/sanoid.nix
    ../../modules/nixos/services/zfs.nix
  ];

  # NOTE: Disabling the default boot options in favor of raspberry pi
  # specific boot options.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.zfs.extraPools = [ zpool ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  services = {
    tailscale.enable = true;

    immich.mediaLocation = "/tank/photos";

    sanoid.datasets."${zpool}" = {
      recursive = true;
      process_children_only = true;
      use_template = [ "default" ];
    };
  };
}
