{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = lib.getExe pkgs.hyprland;
        user = username;
      };
      default_session = initial_session;
    };
  };
}
