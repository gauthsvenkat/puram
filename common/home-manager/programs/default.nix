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

  zsh = import ./zsh.nix { inherit pkgs; };

  wezterm = import ./wezterm.nix { inherit pkgs; };
}
