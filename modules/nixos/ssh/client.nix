{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username}.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  programs.ssh.startAgent = true;
}
