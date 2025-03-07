{ pkgs, hostname, ... }:
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  virtualisation.docker.enable = true;

  programs = {
    # needed for setting user's shell
    zsh.enable = true;
    # to run dynamically linked executables
    nix-ld.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
    ];
    variables = {
      EDITOR = "nvim";
    };
  };

  time.timeZone = "Europe/Amsterdam";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
