{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) headnetDomain lanDomain;
  inherit (targetCfg) username;
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with an sshHostKey
  serverCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? sshHostKey) targetCfgs.nixos;
in
{
  home-manager.users.${username}.programs.ssh.settings =
    let
      # concatMapAttrs :: (hostname::String -> targetCfg -> { alias::String -> sshHost }) -> { hostname::String -> targetCfg } -> { alias::String -> sshHost }
      #   where sshHost = { HostName :: String; User :: String }
      # :: { alias::String -> sshHost }, `<hostname>`, `<hostname>-root` and `<hostname>-hs` per server
      serverAliases = lib.concatMapAttrs (hostName: targetCfg: {
        ${hostName} = {
          HostName = "${hostName}.${lanDomain}";
          User = targetCfg.username;
        };
        "${hostName}-root" = {
          HostName = "${hostName}.${lanDomain}";
          User = "root";
        };
        "${hostName}-hs" = {
          HostName = "${hostName}.${headnetDomain}";
          User = targetCfg.username;
        };
      }) serverCfgs;

      # mapAttrs :: (hostname::String -> targetCfg -> sshHost) -> { hostname::String -> targetCfg } -> { hostname::String -> sshHost }
      #   where sshHost = { HostName, HostKeyAlias, User :: String }
      networkDeviceAliases = lib.mapAttrs (hostName: targetCfg: {
        HostName = targetCfg.lan.ip;
        HostKeyAlias = hostName;
        User = "root";
      }) targetCfgs.openwrt;
    in
    serverAliases // networkDeviceAliases;
}
