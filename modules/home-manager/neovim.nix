{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  pkg = pkgs.neovim;
in
{
  home = {
    packages = with pkgs; [
      curl # blink.cmp
      fd # snacks.picker
      gcc # nvim-treesitter
      git # blink.cmp, snacks.picker, lazy.nvim, nvim-treesitter
      harper # harper_ls
      imagemagick # snacks.image
      inotify-tools # vim.lsp file watching
      python3
      ripgrep # snacks.picker
      tree-sitter
    ];

    sessionVariables.EDITOR = lib.getExe pkg;
  };

  programs = {
    neovim = {
      enable = true;
      # Avoid writing `init.lua` to `~/.config/nvim/`, which links to `assets/configs/nvim/`.
      sideloadInitLua = true;
    };
    zsh.shellAliases."v" = lib.getExe pkg;
  };

  xdg.configFile."nvim".source = mkOutOfStoreSymlink "/etc/nixos/assets/configs/nvim";
}
