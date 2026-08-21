{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../bases/laptop.nix
    ../../bases/niri.nix
    ../../bases/personal.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  home-manager.users.${username}.programs.niri.settings.outputs = {
    "Samsung Electric Company LC32G5xT H000000000" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 144.0;
      };
      position = {
        x = 0;
        y = 0;
      };
      scale = 1.0;
    };

    "eDP-1" = {
      position = {
        x = 2560;
        y = 330;
      };
      scale = 2.5;
    };
  };
}
