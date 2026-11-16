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

  # dewclaw requires the secrets as one JSON object of secret name -> secret value.
  # `sopsSecrets` only takes one file, but we need several,
  # so we use `secretsCommand` and merge them into one object ourselves.
  secretsCommand = lib.getExe (
    pkgs.writeShellApplication {
      name = "router-secrets";
      runtimeInputs = with pkgs; [
        jq
        sops
      ];
      text = ''
        decrypt() {
          local filename=$1 path=$2
          # https://jqlang.org/manual/#to_entries-from_entries-with_entries
          sops decrypt --output-type json "$path" \
            | jq --arg filename "$filename" 'with_entries(.key = "\($filename)/\(.key)")'
        }
        jq --slurp add \
          <(decrypt user ${../../secrets/user.yaml}) \
          <(decrypt wifi ${../../secrets/wifi.yaml})
      '';
    }
  );
}
