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
        tree_alias = level: "${base_command} --tree --git --level=${toString level}";
      in
      {
        l = "${base_command} -l -a";
        l1 = tree_alias 1;
        l2 = tree_alias 2;
        l3 = tree_alias 3;
        l4 = tree_alias 4;
      };
  };
}
