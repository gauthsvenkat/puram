{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  programs = {
    steam.enable = true;
    gamemode.enable = true;
  };

  users.users.${username}.extraGroups = [ "gamemode" ];
}
