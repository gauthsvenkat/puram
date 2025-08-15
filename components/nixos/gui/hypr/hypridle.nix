{ config, ... }:
let
  inherit (config.hostCfg) username;
  inherit (config.hyprCfg) lockScreen;
in
{
  home-manager.users.${username}.services.hypridle = {
    enable = true;
    settings =
      let
        hyprctl = "hyprctl dispatch dpms";
        dpmsOff = "${hyprctl} off";
        dpmsOn = "${hyprctl} on";
      in
      {
        general = {
          lock_cmd = "pidof ${lockScreen} || ${lockScreen}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = dpmsOn;
        };

        listener = [
          {
            timeout = 600;
            on-timeout = dpmsOff;
            on-resume = dpmsOn;
          }
          {
            timeout = 660;
            on-timeout = lockScreen;
          }
        ];
      };
  };
}
