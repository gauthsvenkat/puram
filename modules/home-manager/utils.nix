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
    lychee
    ripgrep
    unzip
    wget
    zip
  ];
}
