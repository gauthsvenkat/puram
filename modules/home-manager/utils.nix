{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ast-grep
    curl
    duf
    fd
    gnumake
    jq
    libqalculate
    ripgrep
    unzip
    wget
    zip
  ];
}
