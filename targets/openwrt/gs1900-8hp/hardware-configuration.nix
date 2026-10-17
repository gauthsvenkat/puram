{ targetCfg, lib, ... }:
let
  inherit (targetCfg) poe;
in
{
  uci.settings.poe = {
    global = [ { inherit (poe) budget; } ];

    # imap1 :: (id::Int -> name::String -> port) -> [ name::String ] -> [ port ]
    #   where port = { id :: Int; name :: String; enable :: Bool }
    port = lib.imap1 (id: name: {
      inherit id name;
      enable = true;
    }) poe.ports;
  };
}
