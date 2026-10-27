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
    users.${username}.home = {
      inherit (nixosCfg) stateVersion;
      inherit username;
      inherit (targetCfg) homeDirectory;
      sessionPath = [ "$HOME/.local/bin" ];
    };

    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit flakeCfg targetCfg;
    };
  };
}
