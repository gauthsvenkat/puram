# Common workstation imports that I want on both nixos and darwin systems.
# This includes development tools and terminal utilities used across platforms.
{ hostCfg, pkgs, ... }:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../modules/common/home-manager.nix
    ../../modules/common/zsh.nix

    ./system.nix
  ];

  home-manager.users.${username} = {
    imports = [
      ../../modules/home-manager/development/lua.nix
      ../../modules/home-manager/development/misc.nix
      ../../modules/home-manager/development/nix.nix
      ../../modules/home-manager/development/python.nix
      ../../modules/home-manager/development/rust.nix

      ../../modules/home-manager/terminal/aider.nix
      ../../modules/home-manager/terminal/bat.nix
      ../../modules/home-manager/terminal/btop.nix
      ../../modules/home-manager/terminal/claude-code.nix
      ../../modules/home-manager/terminal/direnv.nix
      ../../modules/home-manager/terminal/eza.nix
      ../../modules/home-manager/terminal/fastfetch.nix
      ../../modules/home-manager/terminal/fzf.nix
      ../../modules/home-manager/terminal/gemini-cli.nix
      ../../modules/home-manager/terminal/git.nix
      ../../modules/home-manager/terminal/just.nix
      ../../modules/home-manager/terminal/lazygit.nix
      ../../modules/home-manager/terminal/mcfly.nix
      ../../modules/home-manager/terminal/neovim.nix
      ../../modules/home-manager/terminal/nh.nix
      ../../modules/home-manager/terminal/pre-commit.nix
      ../../modules/home-manager/terminal/spotify-player.nix
      ../../modules/home-manager/terminal/utils.nix
      ../../modules/home-manager/terminal/zoxide.nix
      ../../modules/home-manager/terminal/zsh.nix
    ];
    home.packages = [ pkgs.gh ];
  };
}
