{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    age
    rpi-imager
    jellyfin-desktop
  ];
}
