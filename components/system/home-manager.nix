{
  homeDirectory,
  inputs,
  username,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username} = {
      home = {
        stateVersion = "24.11"; # Don't change this

        inherit username homeDirectory;

        packages = [pkgs.just];
      };

      programs.nh.enable = true;
    };

    backupFileExtension = "backup";
  };
}
