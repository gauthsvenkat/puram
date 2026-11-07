{ pkgs, ... }:
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
  };

  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
