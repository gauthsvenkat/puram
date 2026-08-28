{ inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    ../modules/nixos/services/tailscale.nix

    ./server.nix
  ];

  boot = {
    loader.systemd-boot.enable = false;
    # Silences the 26.11 default-change warning.
    zfs.forceImportRoot = false;
  };

  # Spare the microsd the write-per-read of atime updates.
  fileSystems."/".options = [ "noatime" ];
}
