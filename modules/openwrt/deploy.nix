{ hostCfg, ... }:
let
  inherit (hostCfg) lan;
in
{
  deploy = {
    host = lan.ip;
    rebootAllowance = 120;
    rollbackTimeout = 120;
    # To detect the reboot; a rebooting router never closes the connection.
    sshConfig = {
      ServerAliveCountMax = 3;
      ServerAliveInterval = 5;
    };
  };

  sopsSecrets = ../../secrets/router.yaml;
}
