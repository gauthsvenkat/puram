{
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix

    ../../components/gui/kde.nix
    ../../components/cli/yakuake.nix
  ];
}
