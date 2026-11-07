{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  # Reuse one connection for consecutive git operations.
  home-manager.users.${username}.programs.ssh.settings."github.com" = {
    ControlMaster = "auto";
    ControlPath = "/run/user/%i/ssh-%C";
    ControlPersist = "10m";
  };
}
