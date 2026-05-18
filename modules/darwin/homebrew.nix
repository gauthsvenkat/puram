{
  config,
  hostCfg,
  inputs,
  ...
}:
let
  inherit (hostCfg) username;
  inherit (config) nix-homebrew;
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  # NOTE : nix-darwin can integrate with homebrew iff it is installed. Following
  # section handles that.
  nix-homebrew = {
    enable = true;
    user = username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    # Uninstall any formula not in the nix-darwin-generated Brewfile, so brew
    # stays a strict mirror of the nix config.
    onActivation.cleanup = "uninstall";
    taps = builtins.attrNames nix-homebrew.taps;
  };
}
