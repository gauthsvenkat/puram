{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  virtualisation.docker.enable = true;

  users.users.${username}.extraGroups = [ "docker" ];

  home-manager.users.${username}.programs.zsh.oh-my-zsh.plugins = [
    "docker"
    "docker-compose"
  ];
}
