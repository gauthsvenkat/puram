{ targetCfg, ... }:
let
  inherit (targetCfg.ports.qbittorrent) port;
in
{
  services.qbittorrent = {
    enable = true;
    webuiPort = port;
    # `serverConfig` left empty as no way to merge nix config with UI mutable config.
  };
}
