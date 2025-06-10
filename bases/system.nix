# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems, like servers or workstations.
{
  imports = [
    ../components/system/boot.nix
    ../components/system/home-manager.nix
    ../components/system/misc.nix
    ../components/system/networking.nix
    ../components/system/user.nix

    ../components/extra/nix-settings.nix
  ];
}
