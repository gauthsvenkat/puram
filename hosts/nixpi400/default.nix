{ inputs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs-nixos}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    ../../bases/nixos/flavor/server.nix

    ../../components/config.nix
  ];

  # NOTE: Disabling the default boot options in favor of raspberry pi
  # specific boot options.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  hostCfg.hostname = "nixpi400";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };
}
