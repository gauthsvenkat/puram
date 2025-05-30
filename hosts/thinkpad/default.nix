{
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix

    ../../components/core/services/kde.nix
    ../../components/optional/terminal/yakuake.nix
  ];
}
