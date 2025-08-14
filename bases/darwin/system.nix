# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems..
{inputs, ...}: {
  imports = [
    inputs.home-manager-darwin.darwinModules.home-manager
    ../../components/common/home-manager.nix

    ../../components/common/extra/nix-settings.nix
  ];
}
