{config, ...}: let
  inherit (config.hostCfg) username;
in {
  security.pam.services.hyprlock = {};
  home-manager.users.${username}.programs.hyprlock = {
    enable = true;
    # Settings more or less copied from https://github.com/hyprwm/hyprlock/blob/main/assets/example.conf
    settings = {
      general.ignore_empty_input = true;

      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
        }
      ];

      input-field = [
        {
          size = "20%, 5%";
          outline_thickness = 3;
          inner_color = "rgba(0, 0, 0, 0.0)";
          outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
          fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";
          font_color = "rgb(143, 143, 143)";
          fade_on_empty = false;
          rounding = 15;
          font_family = "Monospace";
          placeholder_text = "Input password...";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date '+%H:%M:%S')\"";
          font_size = 120;
          font_family = "Monospace";
          font_color = "rgba(255, 255, 255, 0.6)";
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:60000] echo \"$(date '+%A, %B %d')\"";
          font_size = 25;
          font_family = "Monospace";
          font_color = "rgba(255, 255, 255, 0.6)";
          position = "0, -200";
          halign = "center";
          valign = "top";
        }
      ];
    };
  };
}
