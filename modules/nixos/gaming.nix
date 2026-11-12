{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  programs = {
    gamemode.enable = true;
    steam.enable = true;
  };

  users.users.${username}.extraGroups = [ "gamemode" ];
}
