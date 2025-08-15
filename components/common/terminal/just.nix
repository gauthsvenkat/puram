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
    home.packages = [ pkgs.just ];
    programs.zsh.shellAliases."ju" = lib.getExe pkgs.just;
  };
}
