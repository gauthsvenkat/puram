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
      pkg = pkgs.pre-commit;
    in
    {
      home.packages = [ pkg ];
      programs.zsh.shellAliases = {
        "pc" = "${lib.getExe pkg} run --all-files";
        "pci" = "${lib.getExe pkg} install";
      };
    };
}
