{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.shortcuts = {
    # Application Launchers
    "services/org.kde.dolphin.desktop"."_launch" = "Meta+E";
    "plasmashell"."activate application launcher" = "Meta+Space";

    # Session Management
    "ksmserver"."Lock Session" = "Meta+L";
    "ksmserver"."Log Out" = "Meta+Shift+Esc";

    # Window Management
    "kwin"."Window Close" = "Alt+W";
    "kwin"."Window Fullscreen" = "Alt+F";
    "kwin"."Toggle Window Raise/Lower" = "Alt+V";

    # Focus Navigation (Vim-style)
    "kwin"."Switch Window Left" = "Alt+H";
    "kwin"."Switch Window Down" = "Alt+J";
    "kwin"."Switch Window Up" = "Alt+K";
    "kwin"."Switch Window Right" = "Alt+L";

    # Window Movement (Vim-style)
    "kwin"."Window Pack Left" = "Alt+Shift+H";
    "kwin"."Window Pack Down" = "Alt+Shift+J";
    "kwin"."Window Pack Up" = "Alt+Shift+K";
    "kwin"."Window Pack Right" = "Alt+Shift+L";

    # Desktop Navigation
    "kwin"."Switch to Desktop 1" = "Meta+1";
    "kwin"."Switch to Desktop 2" = "Meta+2";
    "kwin"."Switch to Desktop 3" = "Meta+3";
    "kwin"."Switch to Desktop 4" = "Meta+4";
    "kwin"."Switch to Desktop 5" = "Meta+5";
    "kwin"."Switch to Desktop 6" = "Meta+6";

    # Move Windows to Desktops
    "kwin"."Window to Desktop 1" = "Meta+!";
    "kwin"."Window to Desktop 2" = "Meta+@";
    "kwin"."Window to Desktop 3" = "Meta+#";
    "kwin"."Window to Desktop 4" = "Meta+$";
    "kwin"."Window to Desktop 5" = "Meta+%";
    "kwin"."Window to Desktop 6" = "Meta+^";

    # Additional Useful Shortcuts
    "kwin"."Show Desktop" = "Meta+D";
    "kwin"."Overview" = "Meta+W";
    "kwin"."Walk Through Windows" = "Alt+Tab";
    "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";

    # Quick Tiling
    "kwin"."Window Quick Tile Left" = "Meta+Left";
    "kwin"."Window Quick Tile Right" = "Meta+Right";
    "kwin"."Window Quick Tile Top" = "Meta+Up";
    "kwin"."Window Quick Tile Bottom" = "Meta+Down";
  };
}
