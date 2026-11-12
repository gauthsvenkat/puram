{ targetCfg, ... }:
let
  inherit (targetCfg) gitEmail;
in
{
  programs = {
    git = {
      enable = true;

      ignores = [
        "*.env"
        "*.envrc"
      ];

      lfs.enable = true;

      settings = {
        user = {
          email = gitEmail;
          name = "Gautham Venkataraman";
        };
        init.DefaultBranch = "main";
        pull.rebase = true;
      };
    };

    difftastic = {
      enable = true;
      git = {
        enable = true;
        mode = "both";
      };
    };

    zsh.oh-my-zsh.plugins = [ "git" ];
  };
}
