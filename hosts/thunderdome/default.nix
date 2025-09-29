{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  zpool = "wombocombo";
in
{
  imports = [
    ../../bases/nixos/desktop-environment/kde.nix

    ../../bases/nixos/flavor/personal.nix

    ../../modules/nixos/extra/autologin.nix
    ../../modules/nixos/extra/gaming.nix

    ../../modules/nixos/hardware/nvidia.nix

    ../../modules/nixos/services/sanoid.nix
    ../../modules/nixos/services/zfs.nix

    ./hardware-configuration.nix
  ];

  # NOTE: Without the following disabling of tpm, the boot process
  # gets stuck on "A start job is running for /dev/tpmrm0".
  systemd.tpm2.enable = false;

  boot.zfs.extraPools = [ zpool ];
  services.sanoid.datasets."${zpool}".use_template = [ "default" ];

  home-manager.users.${username}.home.packages = [ pkgs.discord ];
}
