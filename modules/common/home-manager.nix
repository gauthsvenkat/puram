{ hostCfg, ... }:
let
  inherit (hostCfg) username homeDirectory;
in
{
  home-manager = {
    users.${username}.home = {
      stateVersion = "24.11"; # Don't change this
      inherit username homeDirectory;
      # to add ~/.local/bin to $PATH
      sessionPath = [ "$HOME/.local/bin" ];
    };

    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";

    # TODO: Uncomment when moving to support home-manager standalone setup.
    # extraSpecialArgs = {
    #   inherit hostCfg;
    # };
  };
}
