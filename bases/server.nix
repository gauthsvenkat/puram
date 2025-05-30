{
  imports = [
    ./system.nix

    ../components/home-manager.nix

    ../components/services/docker.nix

    ../components/cli/bat.nix
    ../components/cli/btop.nix
    ../components/cli/eza.nix
    ../components/cli/git.nix
    ../components/cli/mcfly.nix
    ../components/cli/zoxide.nix
    ../components/cli/zsh.nix
  ];

  services.openssh.enable = true;
}
