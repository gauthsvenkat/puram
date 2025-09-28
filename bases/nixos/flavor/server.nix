{
  imports = [
    ../../../modules/nixos/services/docker.nix

    ../../../modules/common/terminal/bat.nix
    ../../../modules/common/terminal/btop.nix
    ../../../modules/common/terminal/eza.nix
    ../../../modules/common/terminal/fastfetch.nix
    ../../../modules/common/terminal/git.nix
    ../../../modules/common/terminal/just.nix
    ../../../modules/common/terminal/mcfly.nix
    ../../../modules/common/terminal/nh.nix
    ../../../modules/common/terminal/utils.nix
    ../../../modules/common/terminal/zoxide.nix
    ../../../modules/common/terminal/zsh.nix

    ../system.nix
  ];

  services.openssh.enable = true;
}
