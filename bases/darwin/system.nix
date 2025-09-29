# This config will put together a very basic darwin system.
# It is meant to be used as a foundation for building more
# specific systems.
{ inputs, ... }:
{
  imports = [
    ../common/system.nix

    inputs.home-manager-darwin.darwinModules.home-manager
    inputs.sops-nix-darwin.darwinModules.sops
  ];
}
