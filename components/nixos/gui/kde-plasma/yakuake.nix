{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username} = {
    home.packages = [ pkgs.kdePackages.yakuake ];

    programs.plasma = {
      configFile."yakuakerc" = {
        "Desktop Entry".DefaultProfile = "default.profile";
        Dialogs.FirstRun = false;
        Window.KeepOpen = false;

        Shortcuts = {
          new-session = "Ctrl+Alt+T";
          next-session = "Ctrl+Alt+N";
          next-terminal = "Ctrl+Alt+L";
          previous-session = "Ctrl+Alt+B";
          previous-terminal = "Ctrl+Alt+H";
          split-left-right = "Ctrl+Alt+V";
        };
      };

      shortcuts."yakuake"."toggle-window-state" = "F12";
    };

    xdg.autostart.entries = [
      "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
    ];
  };
}
