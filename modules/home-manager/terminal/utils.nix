{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    duf
    fd
    gnumake
    jq
    ripgrep
    unzip
    wget
    zip
  ];
}
