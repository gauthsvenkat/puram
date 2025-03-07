{ pkgs }:
{
  fastfetch.enable = true;
  eza.enable = true;
  fzf.enable = true;
  bat.enable = true;
  lazygit.enable = true;
  direnv.enable = true;
  nh.enable = true;

  zoxide = {
    enable = true;
    options = [
      "--cmd j"
    ];
  };

  git = {
    enable = true;
    lfs.enable = true;
    userName = "Gautham Venkataraman";
  };

  btop = {
    enable = true;
    settings = {
      color_theme = "gruvbox_dark";
      update_ms = 1000;
      proc_tree = true;
    };
  };

  zsh = {
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
      l = "${pkgs.eza}/bin/eza -l --icons -a";
      lt = "${pkgs.eza}/bin/eza --tree --icons --git --level=3";
      v = "${pkgs.neovim}/bin/nvim";
      b = "${pkgs.bat}/bin/bat";
      lg = "${pkgs.lazygit}/bin/lazygit";
    };
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.p10k.zsh && source ~/.p10k.zsh
    '';
  };
}
