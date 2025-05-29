{ pkgs, hostname, ... }:
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  virtualisation.docker.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs = {
    # needed for setting user's shell
    zsh.enable = true;
    # to run dynamically linked executables
    nix-ld.enable = true;
  };

  environment = {
    systemPackages = [ pkgs.neovim ];
    variables.EDITOR = "nvim";
    # following adds `~/.local/bin` to PATH
    localBinInPath = true;
  };

  time.timeZone = "Europe/Amsterdam";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
