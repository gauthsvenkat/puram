{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
  inherit (lib) getExe;
in
{
  home-manager.users.${username}.programs = {
    bat.enable = true;
    zsh.shellAliases."b" = getExe pkgs.bat;
  };
}
