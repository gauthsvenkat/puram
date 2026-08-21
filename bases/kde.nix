{
  imports = [
    ../modules/nixos/kde-plasma/effects.nix
    ../modules/nixos/kde-plasma/krunner.nix
    ../modules/nixos/kde-plasma/kscreenlocker.nix
    ../modules/nixos/kde-plasma/nightlight.nix
    ../modules/nixos/kde-plasma/plasma-manager.nix
    ../modules/nixos/kde-plasma/powerdevil.nix
    ../modules/nixos/kde-plasma/shortcuts.nix
    ../modules/nixos/kde-plasma/spectacle.nix
    ../modules/nixos/kde-plasma/yakuake.nix

    ./workstation.nix
  ];

  programs.kdeconnect.enable = true;

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
  };
}
