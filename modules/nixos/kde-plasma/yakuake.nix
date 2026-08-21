{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username} =
    let
      pkg = pkgs.kdePackages.yakuake;
    in
    {
      home.packages = [ pkg ];

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
        "${pkg}/share/applications/org.kde.yakuake.desktop"
      ];
    };
}
