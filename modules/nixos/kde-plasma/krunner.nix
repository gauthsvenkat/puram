{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.krunner = {
    shortcuts.launch = "Meta+Space";
    activateWhenTypingOnDesktop = true;
    historyBehavior = "enableSuggestions";
    position = "center";
  };
}
