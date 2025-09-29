{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  package = with pkgs; [ vial ];
in
{
  home-manager.users.${username}.home.packages = package;
  services.udev.packages = package;
}
