{ pkgs, username, ... }:
{
  home-manager.users.${username}.programs = {
    eza.enable = true;
    zsh.shellAliases = {
      l = "${pkgs.eza}/bin/eza -l --icons -a";
      lt = "${pkgs.eza}/bin/eza --tree --icons --git --level=4";
    };
  };
}
