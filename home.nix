{ pkgs, ... }:

let
  username = "ando";
  homeDirectory = "/home/${username}";
in
{
  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "24.11"; # Don't change this
    inherit username;
    inherit homeDirectory;
    packages = with pkgs; [
      meslo-lgs-nf
      cmake
      nodejs
      rustup
      cargo-generate
      nixfmt-rfc-style
      pre-commit
      just
      ttyper
    ];
  };

  programs = {
    fastfetch.enable = true;
    eza.enable = true;
    fzf.enable = true;
    bat.enable = true;
    ripgrep.enable = true;
    lazygit.enable = true;
    direnv.enable = true;
    yazi.enable = true;
    nh.enable = true;
    firefox.enable = true;

    zoxide = {
      enable = true;
      options = [
        "--cmd j"
      ];
    };

    git = {
      enable = true;
      lfs.enable = true;
      userEmail = "gauthsvenkat@gmail.com";
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
        ];
      };
      shellAliases = {
        l = "${pkgs.eza}/bin/eza -l --icons -a";
        lt = "${pkgs.eza}/bin/eza --tree --icons --git --level=3";
        v = "${pkgs.neovim}/bin/nvim";
        b = "${pkgs.bat}/bin/bat";
        y = "${pkgs.yazi}/bin/yazi";
        lg = "${pkgs.lazygit}/bin/lazygit";
      };
      initExtra = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        test -f ~/.p10k.zsh && source ~/.p10k.zsh
        ${pkgs.fastfetch}/bin/fastfetch
      '';
    };
  };
}
