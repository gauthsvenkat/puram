{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  inherit (lib) getExe;
in
{
  home-manager.users.${username}.programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh.shellAliases."da." = "${getExe pkgs.direnv} allow .";
  };
}
