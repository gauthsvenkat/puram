{ hostCfg, ... }:
let
  inherit (hostCfg) homeDirectory;
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      autoupdate = false;

      permission = {
        read = {
          ".env*" = "deny";
          "${homeDirectory}/.ssh/*" = "deny";
        };
      };
    };
  };
}
