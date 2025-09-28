{
  config,
  ...
}:
let
  inherit (config.hostCfg) username;
  inherit (config.hyprCfg)
    brightnessctl
    fileManager
    launcher
    lockScreen
    playerctl
    screenshot
    wezterm
    ;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    bind = [
      # launchers
      "super, t, exec, ${wezterm}"
      "super, e, exec, ${fileManager}"
      "super, space, exec, ${launcher}"

      # session management
      "super, l, exec, ${lockScreen}"
      "super shift, escape, exit"

      # window management
      "super, q, killactive"
      "alt, f, fullscreen"
      "alt, v, togglefloating"

      # focus navifation
      "alt, h, movefocus, l"
      "alt, j, movefocus, d"
      "alt, k, movefocus, u"
      "alt, l, movefocus, r"

      # window movement
      "alt shift, h, movewindow, l"
      "alt shift, j, movewindow, d"
      "alt shift, k, movewindow, u"
      "alt shift, l, movewindow, r"

      # workspace navigation
      "super, j, workspace, +1"
      "super, k, workspace, -1"

      "super, 1, workspace, 1"
      "super, 2, workspace, 2"
      "super, 3, workspace, 3"
      "super, 4, workspace, 4"
      "super, 5, workspace, 5"
      "super, 6, workspace, 6"
      "super, 7, workspace, 7"
      "super, 8, workspace, 8"
      "super, 9, workspace, 9"
      "super, 0, workspace, 10"

      # move windows to workspace
      "super shift, 1, movetoworkspace, 1"
      "super shift, 2, movetoworkspace, 2"
      "super shift, 3, movetoworkspace, 3"
      "super shift, 4, movetoworkspace, 4"
      "super shift, 5, movetoworkspace, 5"
      "super shift, 6, movetoworkspace, 6"
      "super shift, 7, movetoworkspace, 7"
      "super shift, 8, movetoworkspace, 8"
      "super shift, 9, movetoworkspace, 9"
      "super shift, 0, movetoworkspace, 10"

      # screenshot
      ", Print, exec, ${screenshot}"
    ];

    bindm = [
      "alt, mouse:272, movewindow"
      "alt, mouse:273, resizewindow"
    ];

    bindc = [
      "alt, mouse:272, togglefloating"
    ];

    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, ${brightnessctl} s 5%+"
      ",XF86MonBrightnessDown, exec, ${brightnessctl} s 5%-"
    ];

    bindl = [
      ", XF86AudioNext, exec, ${playerctl} next"
      ", XF86AudioPause, exec, ${playerctl} play-pause"
      ", XF86AudioPlay, exec, ${playerctl} play-pause"
      ", XF86AudioPrev, exec, ${playerctl} previous"
    ];
  };
}
