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
  home-manager.users.${username} =
    let
      pkg = pkgs.pre-commit;
    in
    {
      home.packages = [ pkg ];
      programs.zsh.shellAliases = {
        "pc" = "${getExe pkg} run --all-files";
        "pci" = "${getExe pkg} install";
      };
    };
}
