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
    bat.enable = true;
    zsh.shellAliases."b" = getExe pkgs.bat;
  };
}
