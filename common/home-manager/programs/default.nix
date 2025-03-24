{
  username,
  ...
}:
{
  imports = [ ./zsh.nix ];

  home-manager.users.${username}.programs = {
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
      ignores = [".envrc" ".env"];
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark";
        update_ms = 1000;
        proc_tree = true;
      };
    };
  };
}
