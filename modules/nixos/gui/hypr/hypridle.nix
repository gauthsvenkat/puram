{ config, hostCfg, ... }:
let
  inherit (hostCfg) username;
  inherit (config.hyprVars) lockScreen brightnessctl;
in
{
  home-manager.users.${username}.services.hypridle = {
    enable = true;
    settings =
      let
        hyprctl = "hyprctl dispatch dpms";
        dpmsOff = "${hyprctl} off";
        dpmsOn = "${hyprctl} on";

        dimDisplay = "${brightnessctl} set 10%";
        restoreBrightness = "${brightnessctl} set 50%";
      in
      {
        general = {
          lock_cmd = "pidof ${lockScreen} || ${lockScreen}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "${dpmsOn} && ${restoreBrightness}";
        };

        listener = [
          # Dim display after 10 minutes (like KDE AC profile)
          {
            timeout = 600;
            on-timeout = dimDisplay;
            on-resume = restoreBrightness;
          }
          # Turn off display after 15 minutes
          {
            timeout = 900;
            on-timeout = dpmsOff;
            on-resume = "${dpmsOn} && ${restoreBrightness}";
          }
          # Lock screen after 16 minutes
          {
            timeout = 960;
            on-timeout = lockScreen;
          }
        ];
      };
  };
}
