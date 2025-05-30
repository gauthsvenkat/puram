{ pkgs, username, ... }:
{
  home-manager.users.${username}.programs = {
    lazygit.enable = true;
    zsh.shellAliases."lg" = "${pkgs.lazygit}/bin/lazygit";
  };
}
