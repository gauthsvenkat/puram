{
  inputs,
  username,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    users.${username} = {
      home = {
        stateVersion = "24.11"; # Don't change this
        inherit username;
        homeDirectory = "/home/${username}";
        packages = with pkgs; [ just age ];
      };

      programs = {
        fastfetch.enable = true;
        eza.enable = true;
        fzf.enable = true;
        bat.enable = true;
        lazygit.enable = true;
        nh.enable = true;

        direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

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
          userEmail = "gauthsvenkat@gmail.com";
          ignores = [
            ".envrc"
            ".env"
          ];
        };

        btop = {
          enable = true;
          settings = {
            color_theme = "gruvbox_dark";
            update_ms = 1000;
            proc_tree = true;
          };
        };

        mcfly = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          fzf.enable = true;
          keyScheme = "vim";
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
            c = "clear";
            o = "xdg-open";
            open = "xdg-open";
            l = "${pkgs.eza}/bin/eza -l --icons -a";
            lt = "${pkgs.eza}/bin/eza --tree --icons --git --level=4";
            v = "${pkgs.neovim}/bin/nvim";
            b = "${pkgs.bat}/bin/bat";
            lg = "${pkgs.lazygit}/bin/lazygit";
          };
          initContent = ''
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            test -f ~/.p10k.zsh && source ~/.p10k.zsh
            ${pkgs.fastfetch}/bin/fastfetch
          '';
        };
      };

      targets.genericLinux.enable = true;
      fonts.fontconfig.enable = true;
    };

    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
