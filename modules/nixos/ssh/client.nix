{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  programs.ssh.startAgent = true;

  home-manager.users.${username}.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
}
