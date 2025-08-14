{
  imports = [
    ../../../components/nixos/services/docker.nix

    ../../../components/common/terminal/bat.nix
    ../../../components/common/terminal/btop.nix
    ../../../components/common/terminal/eza.nix
    ../../../components/common/terminal/fastfetch.nix
    ../../../components/common/terminal/git.nix
    ../../../components/common/terminal/just.nix
    ../../../components/common/terminal/mcfly.nix
    ../../../components/common/terminal/nh.nix
    ../../../components/common/terminal/utils.nix
    ../../../components/common/terminal/zoxide.nix
    ../../../components/common/terminal/zsh.nix

    ../system.nix
  ];

  services.openssh.enable = true;
}
