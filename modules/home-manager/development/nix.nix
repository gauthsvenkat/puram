{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deadnix
    nil
    nix-output-monitor
    nixfmt
    statix
  ];
}
