{ hostCfg, lib, ... }:
let
  inherit (hostCfg) poe;
in
{
  uci.settings.poe = {
    global = [ { inherit (poe) budget; } ];

    port = lib.imap1 (id: name: {
      inherit id name;
      enable = true;
    }) poe.ports;
  };
}
