{ hostCfg, lib, ... }:
let
  inherit (hostCfg) poe;
in
{
  uci.settings.poe = {
    global = [ { inherit (poe) budget; } ];

    # imap1 :: (Int -> String -> port) -> [ String ] -> [ port ]
    #   where port = { id :: Int; name :: String; enable :: Bool }
    # :: [ port ]
    port = lib.imap1 (id: name: {
      inherit id name;
      enable = true;
    }) poe.ports;
  };
}
