{ config, ... }:
let
  inherit (config.hostCfg) username hostname;
in
{
  services.foldingathome = {
    enable = true;
    user = "gauthsvenkat";
    # TODO: Consider adding the passkey
    extraArgs = [
      "--machine-name"
      "${username}@${hostname}"
    ];
  };
}
