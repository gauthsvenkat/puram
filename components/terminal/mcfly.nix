{username, ...}: {
  home-manager.users.${username}.programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    keyScheme = "vim";
  };
}
