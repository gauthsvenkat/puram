{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username} = {
    home.packages = [ pkgs.pre-commit ];
    programs.zsh.shellAliases = {
      "pc" = "${lib.getExe pkgs.pre-commit} run --all-files";
      "pci" = "${lib.getExe pkgs.pre-commit} install";
    };
  };
}
