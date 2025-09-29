{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    libqalculate
    numbat
  ];
}
