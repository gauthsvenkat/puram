{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    age
    jellyfin-desktop
    rpi-imager
    signal-desktop
  ];
}
