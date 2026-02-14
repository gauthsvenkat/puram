{ hostCfg, ... }:
let
  inherit (hostCfg) homeDirectory;
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    rules = ../../../notnix/llms/rules.md;

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
