{config, ...}: let
  inherit (config.hostCfg) username gitEmail;
in {
  home-manager.users.${username}.programs = {
    git = {
      enable = true;

      difftastic = {
        enable = true;
        enableAsDifftool = true;
      };

      lfs.enable = true;

      userName = "Gautham Venkataraman";
      userEmail = gitEmail;

      extraConfig.init.DefaultBranch = "main";

      ignores = [
        ".envrc"
        ".env"
        "codecompanion-workspace.json"
        "private_key"
      ];
    };
    zsh.oh-my-zsh.plugins = ["git"];
  };
}
