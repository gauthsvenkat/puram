{ pkgs, ... }:
let
  username = "ando";
  homeDirectory = "/home/${username}";
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home = {
        stateVersion = "24.11"; # Don't change this
        inherit username;
        inherit homeDirectory;
        packages = import ./packages.nix { inherit pkgs; };
      };

      targets.genericLinux.enable = true;
      fonts.fontconfig.enable = true;

      programs = import ./programs.nix { inherit pkgs; };
    };
  };
}
