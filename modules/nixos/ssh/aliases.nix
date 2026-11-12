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
  networkDeviceCfgs = targetCfgs.openwrt;
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with an sshHostKey
  serverCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? sshHostKey) targetCfgs.nixos;
in
{
  home-manager.users.${username}.programs.ssh.settings =
    let
      # mapAttrs :: (hostname::String -> targetCfg -> sshHost) -> { hostname::String -> targetCfg } -> { hostname::String -> sshHost }
      #   where sshHost = { HostName, HostKeyAlias, User :: String }
      networkDeviceAliases = lib.mapAttrs (hostName: targetCfg: {
        HostName = targetCfg.lan.ip;
        HostKeyAlias = hostName;
        User = "root";
      }) networkDeviceCfgs;

      # concatMapAttrs :: (hostname::String -> targetCfg -> { alias::String -> sshHost }) -> { hostname::String -> targetCfg } -> { alias::String -> sshHost }
      #   where sshHost = { HostName :: String; User :: String }
      # :: { alias::String -> sshHost }, `<hostname>`, `<hostname>-hs` and `<hostname>-root` per server
      serverAliases = lib.concatMapAttrs (hostName: targetCfg: {
        ${hostName} = {
          HostName = "${hostName}.${lanDomain}";
          User = targetCfg.username;
        };
        "${hostName}-hs" = {
          HostName = "${hostName}.${headnetDomain}";
          User = targetCfg.username;
        };
        "${hostName}-root" = {
          HostName = "${hostName}.${lanDomain}";
          User = "root";
        };
      }) serverCfgs;
    in
    serverAliases // networkDeviceAliases;
}
