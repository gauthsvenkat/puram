{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
  pkg = pkgs.just;
in
{
  home.packages = [ pkg ];
  programs.zsh.shellAliases."ju" = getExe pkg;
}
