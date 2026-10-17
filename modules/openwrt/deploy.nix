{
  targetCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) lan;
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

  # `sopsSecrets` only takes one file; we need `system.yaml` and `wifi.yaml`, so we merge them ourselves.
  secretsCommand = lib.getExe (
    pkgs.writeShellApplication {
      name = "router-secrets";
      runtimeInputs = with pkgs; [
        jq
        sops
      ];
      text = ''
        jq -s add \
          <(sops --output-type json -d ${../../secrets/system.yaml}) \
          <(sops --output-type json -d ${../../secrets/wifi.yaml})
      '';
    }
  );
}
