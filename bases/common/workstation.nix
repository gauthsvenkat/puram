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
      ../../modules/home-manager/cli/atuin.nix
      ../../modules/home-manager/cli/bat.nix
      ../../modules/home-manager/cli/btop.nix
      ../../modules/home-manager/cli/claude-code.nix
      ../../modules/home-manager/cli/direnv.nix
      ../../modules/home-manager/cli/eza.nix
      ../../modules/home-manager/cli/fastfetch.nix
      ../../modules/home-manager/cli/git.nix
      ../../modules/home-manager/cli/just.nix
      ../../modules/home-manager/cli/lazygit.nix
      ../../modules/home-manager/cli/neovim.nix
      ../../modules/home-manager/cli/nh.nix
      ../../modules/home-manager/cli/pre-commit.nix
      ../../modules/home-manager/cli/starship.nix
      ../../modules/home-manager/cli/utils.nix
      ../../modules/home-manager/cli/zoxide.nix
      ../../modules/home-manager/cli/zsh.nix

      ../../modules/home-manager/development/lua.nix
      ../../modules/home-manager/development/misc.nix
      ../../modules/home-manager/development/nix.nix
      ../../modules/home-manager/development/python.nix
      ../../modules/home-manager/development/rust.nix

      ../../modules/home-manager/gui/wezterm.nix
    ];

    home.packages = [ pkgs.gh ];

    programs.starship.presets = [
      "bracketed-segments"
      "nerd-font-symbols"
    ];
  };
}
