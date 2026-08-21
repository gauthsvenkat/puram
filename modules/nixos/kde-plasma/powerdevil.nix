{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.powerdevil = {
    general.pausePlayersOnSuspend = true;

    AC = {
      autoSuspend.action = "nothing";

      dimDisplay = {
        enable = true;
        idleTimeout = 600; # seconds
      };

      inhibitLidActionWhenExternalMonitorConnected = true;
      powerButtonAction = "showLogoutScreen";
      powerProfile = "performance";

      turnOffDisplay = {
        idleTimeout = 900; # seconds
        idleTimeoutWhenLocked = 300; # seconds
      };

      whenLaptopLidClosed = "turnOffScreen";
      whenSleepingEnter = "standbyThenHibernate";
    };

    batteryLevels = {
      criticalAction = "sleep";
      lowLevel = 40; # percent
      criticalLevel = 15; # percent
    };

    battery = {
      autoSuspend = {
        action = "sleep";
        idleTimeout = 1800; # seconds
      };

      dimDisplay = {
        enable = true;
        idleTimeout = 300; # seconds
      };

      inhibitLidActionWhenExternalMonitorConnected = true;
      powerButtonAction = "showLogoutScreen";
      powerProfile = "balanced";

      turnOffDisplay = {
        idleTimeout = 360; # seconds
        idleTimeoutWhenLocked = 60; # seconds
      };

      whenLaptopLidClosed = "sleep";
      whenSleepingEnter = "standbyThenHibernate";
    };

    lowBattery = {
      autoSuspend = {
        action = "sleep";
        idleTimeout = 300; # seconds
      };

      dimDisplay = {
        enable = true;
        idleTimeout = 60; # seconds
      };

      inhibitLidActionWhenExternalMonitorConnected = true;
      powerButtonAction = "showLogoutScreen";
      powerProfile = "powerSaving";

      turnOffDisplay = {
        idleTimeout = 120; # seconds
        idleTimeoutWhenLocked = 30; # seconds
      };

      whenLaptopLidClosed = "sleep";
      whenSleepingEnter = "standbyThenHibernate";
    };
  };
}
