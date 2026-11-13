{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) headnetDomain lanDomain ociDomain;
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
      # :: { alias::String -> sshHost }, `<hostname>`, `<hostname>-hs` and `<hostname>-root` per server, OCI hosts by their public name
      serverAliases = lib.concatMapAttrs (
        hostName: targetCfg:
        let
          hostDomain = if targetCfg ? addresses.vcn then ociDomain else lanDomain;
        in
        {
          ${hostName} = {
            HostName = "${hostName}.${hostDomain}";
            User = targetCfg.username;
          };
          "${hostName}-hs" = {
            HostName = "${hostName}.${headnetDomain}";
            User = targetCfg.username;
          };
          "${hostName}-root" = {
            HostName = "${hostName}.${hostDomain}";
            User = "root";
          };
        }
      ) serverCfgs;
    in
    serverAliases // networkDeviceAliases;
}
