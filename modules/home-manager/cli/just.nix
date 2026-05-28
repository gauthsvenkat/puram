{
  lib,
  pkgs,
  ...
}:
let
  pkg = pkgs.just;
in
{
  home.packages = [ pkg ];
  programs.zsh.shellAliases."ju" = lib.getExe pkg;
}
