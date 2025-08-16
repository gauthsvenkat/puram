# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems, like servers or workstations.
{ inputs, ... }:
{
  imports = [
    ../../components/nixos/system/boot.nix
    ../../components/nixos/system/misc.nix
    ../../components/nixos/system/networking.nix
    ../../components/nixos/system/user.nix

    inputs.home-manager-nixos.nixosModules.home-manager
    inputs.sops-nix-nixos.nixosModules.sops

    ../common/system.nix
  ];
}
