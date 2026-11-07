{
  boot.kernel.sysctl."kernel.panic" = 10;

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";
}
