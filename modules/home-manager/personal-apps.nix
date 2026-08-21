{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    age
    localsend
    rpi-imager
    jellyfin-desktop
  ];
}
