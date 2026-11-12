{
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings.experimental-features = [
      "flakes"
      "nix-command"
    ];
  };
  nixpkgs.config.allowUnfree = true;
}
