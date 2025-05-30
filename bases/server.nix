{
  imports = [
    ./system.nix

    ../components/core/home-manager.nix

    ../components/optional/services/docker.nix

    ../components/optional/terminal/bat.nix
    ../components/optional/terminal/btop.nix
    ../components/optional/terminal/eza.nix
    ../components/optional/terminal/git.nix
    ../components/optional/terminal/mcfly.nix
    ../components/optional/terminal/zoxide.nix
    ../components/optional/terminal/zsh.nix
  ];

  services.openssh.enable = true;
}
