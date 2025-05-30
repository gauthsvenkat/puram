let
  zpool = "wombocombo";
in
{
  imports = [
    ./hardware-configuration.nix

    ../../bases/personal.nix

    ../../components/core/services/kde.nix
    ../../components/core/services/nvidia.nix
    ../../components/core/services/zfs.nix

    ../../components/optional/gaming.nix

    ../../components/optional/terminal/yakuake.nix
    ../../components/optional/services/sanoid.nix
  ];

  # NOTE: Without the following disabling of tpm, the boot process
  # gets stuck on "A start job is running for /dev/tpmrm0".
  systemd.tpm2.enable = false;

  boot.zfs.extraPools = [ zpool ];
  services.sanoid.datasets."${zpool}".use_template = [ "default" ];
}
