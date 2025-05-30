{ username, ... }:
{
  home-manager.users.${username}.programs = {
    git = {
      enable = true;
      lfs.enable = true;
      userName = "Gautham Venkataraman";
      userEmail = "gauthsvenkat@gmail.com";
      ignores = [
        ".envrc"
        ".env"
      ];
    };
    zsh.oh-my-zsh.plugins = [ "git" ];
  };
}
