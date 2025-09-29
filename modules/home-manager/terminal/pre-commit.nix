{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
  pkg = pkgs.pre-commit;
in
{
  home.packages = [ pkg ];
  programs.zsh.shellAliases = {
    "pc" = "${getExe pkg} run --all-files";
    "pci" = "${getExe pkg} install";
  };
}
