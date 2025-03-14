{
  pkgs,
  username,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./programs
  ];

  home-manager = {
    users.${username} = {
      home = {
        stateVersion = "24.11"; # Don't change this
        inherit username;
        homeDirectory = "/home/${username}";

        packages = with pkgs; [
          unzip
          lazydocker
          just
          pre-commit
          nixfmt-rfc-style
        ];
      };

      targets.genericLinux.enable = true;
      fonts.fontconfig.enable = true;
    };

    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
