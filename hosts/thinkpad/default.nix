{
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix

    ../../components/core/kde.nix
    ../../components/optional/terminal/yakuake.nix
  ];
}
