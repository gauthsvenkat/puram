{ hostCfg, ... }:
let
  inherit (hostCfg) username homeDirectory;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = homeDirectory;
  };
}
