{ targetCfg, lib, ... }:
let
  inherit (targetCfg) lan;
in
{
  uci.settings.poe = {
    global = [ { budget = 70; } ];

    # imap1 :: (id::Int -> name::String -> port) -> [ name::String ] -> [ port ]
    #   where port = { id :: Int; name :: String; enable :: Bool }
    port = lib.imap1 (id: name: {
      inherit id name;
      enable = true;
    }) lan.ports;
  };
}
