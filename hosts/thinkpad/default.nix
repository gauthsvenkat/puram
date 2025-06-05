{
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix

    ../../components/gui/kde/kde.nix
    ../../components/gui/kde/yakuake.nix
  ];
}
