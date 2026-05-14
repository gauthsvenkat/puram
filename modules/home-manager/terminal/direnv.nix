{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship.settings.direnv.disabled = false;

    zsh.shellAliases."da." = "${lib.getExe pkgs.direnv} allow .";

    git.ignores = [ ".direnv" ];
  };
}
