{
  config,
  inputs,
  ...
}: let
  inherit (config.hostCfg) username homeDirectory;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    users.${username}.home = {
      stateVersion = "24.11"; # Don't change this
      inherit username homeDirectory;
    };

    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";
  };
}
