# This config will put together a very basic system.
# It is meant to be used as a foundation for building
# more specific systems, like servers or workstations.
{
  imports = [
    ../components/core/boot.nix
    ../components/core/networking.nix
    ../components/core/nix-settings.nix
    ../components/core/misc.nix
    ../components/core/user.nix
  ];
}
