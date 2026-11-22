{ inputs, ... }:
{
  imports = [
    ../../../bases/nixos/server.nix

    ../../../modules/nixos/services/tailscale.nix

    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot = {
    loader.systemd-boot.enable = false;
    # The sd-card image turns on ZFS, which warns about `zfs.forceImportRoot`
    # if we don't explicitly turn it off.
    supportedFilesystems.zfs = false;
  };

  # Spare the microsd the write-per-read of atime updates.
  fileSystems."/".options = [ "noatime" ];
}
