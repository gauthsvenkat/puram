{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager = {
    users.${username}.home = {
      stateVersion = "26.05";
      inherit username;
      inherit (targetCfg) homeDirectory;
      # to add ~/.local/bin to $PATH
      sessionPath = [ "$HOME/.local/bin" ];
    };

    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit targetCfg;
    };
  };
}
