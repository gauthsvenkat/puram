{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deadnix
    nil
    nix-fast-build
    nix-output-monitor
    nixfmt
    statix
  ];
}
