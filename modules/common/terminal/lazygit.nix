{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  inherit (lib) getExe;
in
{
  home-manager.users.${username}.programs = {
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
