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

    git.ignores = [ ".direnv" ];

    zsh.shellAliases."da." = "${lib.getExe pkgs.direnv} allow .";
  };
}
