{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt
    nix-output-monitor
  ];
}
