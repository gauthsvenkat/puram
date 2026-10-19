{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ast-grep
    curl
    duf
    fd
    git-filter-repo
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
