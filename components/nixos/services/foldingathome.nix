{config, ...}: let
  inherit (config.hostCfg) username hostname;
in {
  services.foldingathome = {
    enable = true;
    user = "Anonymous";
    # TODO: Consider adding the passkey
    extraArgs = [
      "--machine-name"
      "${username}@${hostname}"
    ];
  };
}
