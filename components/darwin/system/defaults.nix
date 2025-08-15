{
  system.defaults = {
    NSGlobalDomain = {
      AppleEnableMouseSwipeNavigateWithScrolls = false;
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      AppleShowAllExtensions = false;
      AppleSpacesSwitchOnActivate = false;
      NSWindowResizeTime = 0.05;
    };

    dock = {
      magnification = true;
      minimize-to-application = true;
      autohide = true;
      autohide-delay = 0.0;
      expose-animation-duration = 0.1;
    };

    finder = {
      AppleShowAllExtensions = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      NewWindowTarget = "Recents";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };

    spaces.spans-displays = true;
  };
}
