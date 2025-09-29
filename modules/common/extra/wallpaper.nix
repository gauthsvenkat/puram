{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.home.file."Pictures/wallpapers" = {
    source = ../../../notnix/wallpapers;
    recursive = true;
  };
}
