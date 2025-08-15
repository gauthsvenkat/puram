{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  # Neovim is installed through NixOS so it is also available to root.
  # But additional dependencies are installed using home-manager since
  # they are only required for the user's nvim configuration. The actual
  # configuration lives in a separate repo.
  environment = {
    systemPackages = [pkgs.neovim];
    variables.EDITOR = "nvim";
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      bat # fzf-lua
      curl # blink.cmp
      fd # fzf-lua
      fzf # fzf-lua
      gcc # nvim-treesitter
      git # blink.cmp, fzf-lua, lazy.nvim, nvim-treesitter
      python3
      ripgrep # fzf-lua
    ];

    programs = {
      neovim.enable = true;
      zsh.shellAliases."v" = lib.getExe pkgs.neovim;
    };
  };
}
