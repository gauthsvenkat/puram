{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.krunner = {
    activateWhenTypingOnDesktop = true;
    historyBehavior = "enableSuggestions";
    position = "center";
    shortcuts.launch = "Meta+Space";
  };
}
