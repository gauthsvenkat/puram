{
  targetCfg,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  imports = [
    ../../../bases/nixos/niri.nix
    ../../../bases/nixos/personal.nix

    ../../../modules/nixos/gaming.nix

    ../../../modules/nixos/hardware/nvidia.nix

    ../../../modules/nixos/services/tailscale.nix

    ./hardware-configuration.nix
    ./monitors.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Load nvidia early in initrd to prevent race with `simpledrm` - without this,
    # SDDM sometimes starts before `nvidia-drm` is ready, resulting in 720p fallback.
    initrd.kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
    ];
  };

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = username;
      };
      defaultSession = "niri";
    };
    ratbagd.enable = true;
  };

  home-manager.users.${username}.home.packages = [ pkgs.discord ];
}
