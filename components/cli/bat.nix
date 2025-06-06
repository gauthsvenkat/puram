{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username}.programs = {
    bat.enable = true;
    zsh.shellAliases."b" = "${pkgs.bat}/bin/bat";
  };
}
