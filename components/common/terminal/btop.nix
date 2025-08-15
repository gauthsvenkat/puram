{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs.btop = {
    enable = true;
    settings = {
      color_theme = "gruvbox_dark";
      update_ms = 1000;
    };
  };
}
