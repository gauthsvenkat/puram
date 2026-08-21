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
    ../../bases/desktop-environment/niri.nix

    ../../bases/flavor/personal.nix

    ../../modules/nixos/extra/gaming.nix

    ../../modules/nixos/hardware/nvidia.nix

    ../../modules/nixos/services/sanoid.nix
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/zfs.nix

    ./hardware-configuration.nix
  ];

  boot = {
    # Load nvidia early in initrd to prevent race with simpledrm - without this,
    # SDDM sometimes starts before nvidia-drm is ready, resulting in 720p fallback.
    initrd.kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
    ];

    zfs.extraPools = [ zpool ];
  };

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = username;
      };
      defaultSession = "niri";
    };

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
