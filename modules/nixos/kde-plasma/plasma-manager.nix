{ inputs, targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username} = {
    imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

    programs.plasma = {
      enable = true;

      configFile."plasmaparc".General.AudioFeedback = false;

      kwin.virtualDesktops = {
        number = 3;
        rows = 1;
      };

      session = {
        general.askForConfirmationOnLogout = true;
        sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
      };

      workspace = {
        colorScheme = "BreezeDark";
        lookAndFeel = "org.kde.breezedark.desktop";
        inherit (targetCfg) wallpaper;
      };
    };
  };
}
