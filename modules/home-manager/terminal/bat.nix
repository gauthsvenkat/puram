{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    bat.enable = true;
    zsh.shellAliases."b" = lib.getExe pkgs.bat;
  };
}
