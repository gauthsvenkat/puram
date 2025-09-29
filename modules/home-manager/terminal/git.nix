{ hostCfg, ... }:
let
  inherit (hostCfg) gitEmail;
in
{
  programs = {
    git = {
      enable = true;

      difftastic = {
        enable = true;
        enableAsDifftool = true;
      };

      lfs.enable = true;

      userName = "Gautham Venkataraman";
      userEmail = gitEmail;

      extraConfig = {
        init.DefaultBranch = "main";
        pull.rebase = true;
      };

      ignores = [
        "*.envrc"
        "*.env"
      ];
    };
    zsh.oh-my-zsh.plugins = [ "git" ];
  };
}
