{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) homeDirectory;
  uvx = lib.getExe' pkgs.uv "uvx";
in
{
  programs = {
    claude-code = {
      enable = true;

      rules."general" = ../../../notnix/llms/rules.md;

      mcpServers = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
        };
        ref = {
          type = "http";
          url = "https://api.ref.tools/mcp";
        };
        CodeGraphContext = {
          type = "stdio";
          command = uvx;
          args = [
            "--from"
            "codegraphcontext"
            "cgc"
            "mcp"
            "start"
          ];
        };
        markitdown = {
          type = "stdio";
          command = uvx;
          args = [ "markitdown-mcp" ];
        };
      };

      settings = {
        env.DISABLE_TELEMETRY = "1";
        theme = "dark";
        cleanupPeriodDays = 7;
        includeCoAuthoredBy = false;

        permissions = {
          defaultMode = "default";
          deny = [
            "Read(*.env*)"
            "Read(${homeDirectory}/.ssh/*)"
          ];
        };
      };
    };

    git.ignores = [
      ".claude/"
      "CLAUDE.local.md"
    ];
  };
}
