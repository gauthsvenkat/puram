{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  inherit (lib) getExe;
in
{
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = getExe pkgs.hyprland;
        user = username;
      };
      default_session = initial_session;
    };
  };
}
