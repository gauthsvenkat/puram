{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  packages = with pkgs; [
    via
    vial
  ];
in
{
  home-manager.users.${username}.home = { inherit packages; };
  services.udev = { inherit packages; };
}
