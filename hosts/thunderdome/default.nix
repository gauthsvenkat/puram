{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
  zpool = "wombocombo";
in {
  imports = [
    ./hardware-configuration.nix

    ../../bases/personal.nix
    ../../bases/workstation-kde.nix

    ../../components/config.nix

    ../../components/hardware/nvidia.nix

    ../../components/services/sanoid.nix
    ../../components/services/zfs.nix

    ../../components/extra/autologin.nix
    ../../components/extra/gaming.nix
  ];

  hostCfg.hostname = "thunderdome";

  # NOTE: Without the following disabling of tpm, the boot process
  # gets stuck on "A start job is running for /dev/tpmrm0".
  systemd.tpm2.enable = false;

  boot.zfs.extraPools = [zpool];
  services.sanoid.datasets."${zpool}".use_template = ["default"];

  home-manager.users.${username}.home.packages = [pkgs.discord];
}
