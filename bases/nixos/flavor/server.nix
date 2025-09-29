{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../../modules/common/home-manager.nix
    ../../../modules/common/zsh.nix
    ../../../modules/nixos/services/docker.nix

    ../system.nix
  ];

  home-manager.users.${username}.imports = [
    ../../../modules/home-manager/terminal/bat.nix
    ../../../modules/home-manager/terminal/btop.nix
    ../../../modules/home-manager/terminal/eza.nix
    ../../../modules/home-manager/terminal/fastfetch.nix
    ../../../modules/home-manager/terminal/git.nix
    ../../../modules/home-manager/terminal/just.nix
    ../../../modules/home-manager/terminal/mcfly.nix
    ../../../modules/home-manager/terminal/nh.nix
    ../../../modules/home-manager/terminal/utils.nix
    ../../../modules/home-manager/terminal/zoxide.nix
    ../../../modules/home-manager/terminal/zsh.nix
  ];

  services.openssh.enable = true;
}
