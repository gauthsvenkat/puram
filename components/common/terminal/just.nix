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
  home-manager.users.${username} =
    let
      pkg = pkgs.just;
    in
    {
      home.packages = [ pkg ];
      programs.zsh.shellAliases."ju" = lib.getExe pkg;
    };
}
