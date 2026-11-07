{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    gh
    libreoffice-stable
    mpv
    spotify
    stirling-pdf-desktop
    vscode
  ];
}
