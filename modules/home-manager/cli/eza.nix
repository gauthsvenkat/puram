{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    eza.enable = true;
    zsh.shellAliases =
      let
        base_command = "${lib.getExe pkgs.eza} --group-directories-last --icons";
      in
      {
        l = "${base_command} -l -a";
        lt = "${base_command} --tree --git --level=4";
      };
  };
}
