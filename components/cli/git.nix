{username, ...}: {
  home-manager.users.${username}.programs = {
    git = {
      enable = true;

      difftastic = {
        enable = true;
        enableAsDifftool = true;
      };

      lfs.enable = true;

      userName = "Gautham Venkataraman";
      userEmail = "gauthsvenkat@gmail.com";

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
