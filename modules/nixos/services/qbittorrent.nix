{ targetCfg, ... }:
let
  inherit (targetCfg) ports;
in
{
  services.qbittorrent = {
    enable = true;
    webuiPort = ports.qbittorrent;
    # `serverConfig` left empty as no way to merge nix config with UI mutable config.
    # NOTE: Set Web UI → Server domains to `qbittorrent.<domain>` in the UI to pass
    # host-header / origin check.
  };
}
