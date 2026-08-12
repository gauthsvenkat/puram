{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ast-grep
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
