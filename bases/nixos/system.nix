# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems, like servers or workstations.
{ inputs, ... }:
{
  imports = [
    ../../modules/nixos/system/boot.nix
    ../../modules/nixos/system/misc.nix
    ../../modules/nixos/system/networking.nix
    ../../modules/nixos/system/user.nix

    ../common/system.nix

    inputs.home-manager-nixos.nixosModules.home-manager
    inputs.sops-nix-nixos.nixosModules.sops
  ];
}
