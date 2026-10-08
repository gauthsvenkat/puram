{
  imports = [
    ../../modules/nixos/niri/apps.nix
    ../../modules/nixos/niri/keybinds.nix
    ../../modules/nixos/niri/niri.nix
    ../../modules/nixos/niri/noctalia.nix
    ../../modules/nixos/niri/screenshot.nix
    ../../modules/nixos/niri/window-rules.nix

    ./workstation.nix
  ];

  services.displayManager.ly.enable = true;
}
