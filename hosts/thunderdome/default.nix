{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username zpool;
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

  # Load nvidia early in initrd to prevent race with simpledrm — without this,
  # SDDM sometimes starts before nvidia-drm is ready, resulting in 720p fallback.
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
    "nvidia_uvm"
  ];

  # Enable cross-compilation for ARM builds
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.zfs.extraPools = [ zpool ];
  services = {
    sanoid.datasets = {
      "${zpool}" = {
        recursive = true;
        process_children_only = true;
        use_template = [ "default" ];
      };
      "${zpool}/cache".autosnap = false;
    };
    ratbagd.enable = true;
  };

  home-manager.users.${username}.home.packages = [ pkgs.discord ];
}
