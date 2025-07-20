{config, ...}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username}.home.file."Pictures/wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };
}
