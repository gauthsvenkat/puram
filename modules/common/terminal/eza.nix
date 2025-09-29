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
    eza.enable = true;
    zsh.shellAliases =
      let
        base_command = "${getExe pkgs.eza} --group-directories-last --icons";
      in
      {
        l = "${base_command} -l -a";
        lt = "${base_command} --tree --git --level=4";
      };
  };
}
