{ targetCfg, ... }:
let
  inherit (targetCfg.ports.qbittorrent) port;
in
{
  services.qbittorrent = {
    enable = true;
    webuiPort = port;
    # `serverConfig` left empty as no way to merge nix config with UI mutable config.
    # NOTE: Set Web UI → Server domains to `qbittorrent.<domain>` in the UI to pass
    # host-header / origin check.
  };
}
