{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    lazygit = {
      enable = true;
      settings.keybinding.universal = {
        quit = "q";
        quit-alt1 = "<delete>";
      };
    };
    zsh.shellAliases."lg" = lib.getExe pkgs.lazygit;
  };
}
