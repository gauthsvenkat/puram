{
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (targetCfg) username homeDirectory;
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with a syncthingId
  syncthingCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? syncthingId) targetCfgs.nixos;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = homeDirectory;

    settings = {
      # mapAttrs :: (hostname::String -> targetCfg -> device) -> { hostname::String -> targetCfg } -> { hostname::String -> device }
      #   where device = { id :: String }
      devices = lib.mapAttrs (_: targetCfg: { id = targetCfg.syncthingId; }) syncthingCfgs;

      folders =
        let
          ignorePatterns = [
            "(?d)*.pyc"
            "(?d)*~"
            "(?d).Trash-*"
            "(?d)._*"
            "(?d).aider.tags.cache.v4"
            "(?d).direnv"
            "(?d).gradle"
            "(?d).hypothesis"
            "(?d).ipynb_checkpoints"
            "(?d).mypy_cache"
            "(?d).ruff_cache"
            "(?d).venv"
            "(?d).~lock.*#"
            "(?d)__pycache__"
            "(?d)node_modules"
            "(?d)target"
          ];
        in
        # genAttrs :: [ dirName::String ] -> (dirName::String -> folder) -> { dirName::String -> folder }
        #   where folder = { path :: String; devices :: [ hostname::String ]; ignorePatterns :: [ String ] }
        lib.genAttrs
          [
            "Documents"
            "Downloads"
            "storage"
          ]
          (dirName: {
            path = "${homeDirectory}/${dirName}";
            devices = lib.attrNames syncthingCfgs;
            inherit ignorePatterns;
          });

      # LAN-only sync: skip global discovery, relays, and UPnP NAT punching.
      # https://docs.syncthing.net/users/config.html#config-option-options.globalannounceenabled
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
    };
  };
}
