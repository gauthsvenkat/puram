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
  home-manager.users.${username} =
    let
      pkg = pkgs.aider-chat-with-playwright;
    in
    {
      home = {
        packages = [ pkg ];
        sessionVariables.AIDER_VIM = "true";
      };

      programs = {
        zsh.shellAliases."ai" = getExe pkg;
        git.ignores = [ ".aider*" ];
      };
    };
}
