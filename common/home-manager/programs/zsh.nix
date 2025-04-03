{ pkgs, username, ... }:
{
  home-manager.users.${username}.programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "docker"
        "docker-compose"
        "git"
        "fzf"
        "zoxide"
        "vi-mode"
      ];
    };
    shellAliases = {
      c = "clear";
      o = "xdg-open";
      open = "xdg-open";
      l = "${pkgs.eza}/bin/eza -l --icons -a";
      lt = "${pkgs.eza}/bin/eza --tree --icons --git --level=4";
      v = "${pkgs.neovim}/bin/nvim";
      b = "${pkgs.bat}/bin/bat";
      lg = "${pkgs.lazygit}/bin/lazygit";
    };
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.p10k.zsh && source ~/.p10k.zsh
      ${pkgs.fastfetch}/bin/fastfetch
    '';
  };
}
