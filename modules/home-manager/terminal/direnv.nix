{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
in
{
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh.shellAliases."da." = "${getExe pkgs.direnv} allow .";
  };
}
