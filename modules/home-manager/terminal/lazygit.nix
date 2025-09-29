{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
in
{
  programs = {
    lazygit = {
      enable = true;
      settings.keybinding.universal = {
        quit = "q";
        quit-alt1 = "<delete>";
      };
    };
    zsh.shellAliases."lg" = getExe pkgs.lazygit;
  };
}
