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
    bat.enable = true;
    zsh.shellAliases."b" = getExe pkgs.bat;
  };
}
