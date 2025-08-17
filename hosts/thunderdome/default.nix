{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
  zpool = "wombocombo";
in
{
  imports = [
    ../../bases/nixos/desktop-environment/kde.nix

    ../../bases/nixos/flavor/personal.nix

    ../../components/variables.nix

    ../../components/nixos/extra/autologin.nix
    ../../components/nixos/extra/gaming.nix

    ../../components/nixos/hardware/nvidia.nix

    ../../components/nixos/services/sanoid.nix
    ../../components/nixos/services/zfs.nix

    ./hardware-configuration.nix
  ];

  # NOTE: Without the following disabling of tpm, the boot process
  # gets stuck on "A start job is running for /dev/tpmrm0".
  systemd.tpm2.enable = false;

  boot.zfs.extraPools = [ zpool ];
  services.sanoid.datasets."${zpool}".use_template = [ "default" ];

  home-manager.users.${username}.home.packages = [ pkgs.discord ];
}
