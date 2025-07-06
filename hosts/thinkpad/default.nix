{username, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix
    ../../bases/workstation-kde.nix
  ];

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };
}
