{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username}.programs = {
    eza.enable = true;
    zsh.shellAliases = let
      base_command = "${pkgs.eza}/bin/eza --group-directories-last --icons";
    in {
      l = "${base_command} -l -a";
      lt = "${base_command} --tree --git --level=4";
    };
  };
}
