{ inputs, targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username} = {
    imports = [ inputs.nix-index-database.homeModules.default ];

    programs = {
      nix-index-database.comma.enable = true;
      # HACK: comma's autocompletion only suggests `man`.
      # `_precommand` completes the command after `,` and its arguments instead.
      # https://zsh.sourceforge.io/Doc/Release/Completion-System.html#index-_005fprecommand
      zsh.initContent = "compdef _precommand ,";
    };
  };
}
