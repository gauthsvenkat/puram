# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems, like servers or workstations.
{
  imports = [
    ../components/boot.nix
    ../components/misc.nix
    ../components/networking.nix
    ../components/user.nix

    ../components/other/nix-settings.nix
  ];
}
