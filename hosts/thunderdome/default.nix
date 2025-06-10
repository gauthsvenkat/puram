let
  zpool = "wombocombo";
in {
  imports = [
    ./hardware-configuration.nix

    ../../bases/personal.nix

    ../../components/hardware/nvidia.nix

    ../../components/gui/kde.nix

    ../../components/services/sanoid.nix
    ../../components/services/zfs.nix

    ../../components/terminal/yakuake.nix

    ../../components/extra/gaming.nix
  ];

  # NOTE: Without the following disabling of tpm, the boot process
  # gets stuck on "A start job is running for /dev/tpmrm0".
  systemd.tpm2.enable = false;

  boot.zfs.extraPools = [zpool];
  services.sanoid.datasets."${zpool}".use_template = ["default"];
}
