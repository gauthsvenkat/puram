# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems, like servers or workstations.
{ inputs, ... }:
{
  imports = [
    ../modules/nixos/system/boot.nix
    ../modules/nixos/system/home-manager.nix
    ../modules/nixos/system/misc.nix
    ../modules/nixos/system/networking.nix
    ../modules/nixos/system/nix-settings.nix
    ../modules/nixos/system/user.nix
    ../modules/nixos/system/wifi.nix
    ../modules/nixos/system/zsh.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];
}
