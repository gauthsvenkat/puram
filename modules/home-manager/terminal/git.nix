{ hostCfg, ... }:
let
  inherit (hostCfg) gitEmail;
in
{
  programs = {
    git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user = {
          name = "Gautham Venkataraman";
          email = gitEmail;
        };
        init.DefaultBranch = "main";
        pull.rebase = true;
      };

      ignores = [
        "*.envrc"
        "*.env"
      ];
    };

    difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
    };

    zsh.oh-my-zsh.plugins = [ "git" ];
  };
}
