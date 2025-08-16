{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.krunner = {
    activateWhenTypingOnDesktop = true;
    historyBehavior = "enableSuggestions";
    position = "center";
  };
}
