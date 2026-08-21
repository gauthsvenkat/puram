{
  lib,
  pkgs,
  ...
}:
let
  pkg = pkgs.neovim;
in
{
  home = {
    packages = with pkgs; [
      bat # fzf-lua
      curl # blink.cmp
      fd # fzf-lua
      fzf # fzf-lua
      gcc # nvim-treesitter
      git # blink.cmp, fzf-lua, lazy.nvim, nvim-treesitter
      harper # harper_ls
      imagemagick # snacks.image
      python3
      ripgrep # fzf-lua
      tree-sitter
    ];

    sessionVariables.EDITOR = "nvim";
  };

  programs = {
    neovim = {
      enable = true;
      # Avoid writing init.lua to ~/.config/nvim/ - managed imperatively via a separate git repo.
      sideloadInitLua = true;
    };
    zsh.shellAliases."v" = lib.getExe pkg;
  };
}
