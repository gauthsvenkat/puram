{
  flakeCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) headnetDomain lanDomain;
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with an sshHostKey
  serverCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? sshHostKey) targetCfgs.nixos;
in
{
  # mapAttrs :: (hostname::String -> targetCfg -> knownHost) -> { hostname::String -> targetCfg } -> { hostname::String -> knownHost }
  #   where knownHost = { extraHostNames :: [ String ]; publicKey :: String }
  programs.ssh.knownHosts = lib.mapAttrs (hostName: targetCfg: {
    extraHostNames = [
      "${hostName}.${headnetDomain}"
      "${hostName}.${lanDomain}"
    ];
    publicKey = targetCfg.sshHostKey;
  }) serverCfgs;
}
