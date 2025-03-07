{
  pkgs,
  username,
  inputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    users.${username} = {
      home = {
        stateVersion = "24.11"; # Don't change this
        inherit username;
        homeDirectory = "/home/${username}";

        packages = with pkgs; [
          just
          pre-commit
          nixfmt-rfc-style
        ];
      };

      targets.genericLinux.enable = true;
      fonts.fontconfig.enable = true;

      programs = import ./programs { inherit pkgs; };
    };

    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
