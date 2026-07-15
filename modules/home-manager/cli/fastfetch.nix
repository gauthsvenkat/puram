{ lib, pkgs, ... }:
{
  programs = {
    fastfetch.enable = true;

    zsh.shellAliases."ff" = lib.getExe pkgs.fastfetch;
  };
}
