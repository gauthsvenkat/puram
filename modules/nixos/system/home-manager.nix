{
  flakeCfg,
  nixosCfg,
  targetCfg,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  home-manager = {
    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit flakeCfg targetCfg;
    };

    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username}.home = {
      inherit username;
      inherit (targetCfg) homeDirectory;
      sessionPath = [ "$HOME/.local/bin" ];
      inherit (nixosCfg) stateVersion;
    };
  };
}
