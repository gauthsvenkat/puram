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

  # Enable cross-compilation for ARM builds
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.zfs.extraPools = [ zpool ];
  services = {
    sanoid.datasets."${zpool}".use_template = [ "default" ];
    ratbagd.enable = true;
  };

  home-manager.users.${username}.home.packages = [ pkgs.discord ];
}
