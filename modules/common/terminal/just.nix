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
  home-manager.users.${username} =
    let
      pkg = pkgs.just;
    in
    {
      home.packages = [ pkg ];
      programs.zsh.shellAliases."ju" = getExe pkg;
    };
}
