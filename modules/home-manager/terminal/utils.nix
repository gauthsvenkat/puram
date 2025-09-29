{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    fd
    gnumake
    jq
    ripgrep
    unzip
    wget
    zip
  ];
}
