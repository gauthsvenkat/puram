{
  pkgs,
  username,
  ...
}: {
  # needed for setting user's shell
  programs.zsh.enable = true;

  users.users.${username}.shell = pkgs.zsh;

  home-manager.users.${username}.programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["vi-mode"];
    };
    shellAliases = {
      c = "clear";
    };
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      test -f ~/.p10k.zsh && source ~/.p10k.zsh
    '';
  };
}
