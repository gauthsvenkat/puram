{
  imports = [
    ./system.nix

    ../components/services/docker.nix

    ../components/terminal/bat.nix
    ../components/terminal/btop.nix
    ../components/terminal/eza.nix
    ../components/terminal/fastfetch.nix
    ../components/terminal/git.nix
    ../components/terminal/mcfly.nix
    ../components/terminal/nh.nix
    ../components/terminal/utils.nix
    ../components/terminal/zoxide.nix
    ../components/terminal/zsh.nix
  ];

  services.openssh.enable = true;
}
