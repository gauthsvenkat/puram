{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = let
    pkg = pkgs.aider-chat-with-playwright;
  in {
    home = {
      packages = [pkg];
      sessionVariables.AIDER_VIM = "true";
    };

    programs = {
      zsh.shellAliases."ai" = "${pkg}/bin/aider";
      git.ignores = [".aider*"];
    };
  };
}
