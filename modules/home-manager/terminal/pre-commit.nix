{
  lib,
  pkgs,
  ...
}:
let
  pkg = pkgs.prek;
in
{
  home.packages = [ pkg ];
  programs.zsh.shellAliases = {
    "pc" = "${lib.getExe pkg} run --all-files";
    "pci" = "${lib.getExe pkg} install";
  };
}
