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

      context = ../../../assets/configs/CLAUDE.md;

      mcpServers = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
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
          defaultMode = "auto";

          deny = [
            "Read(*.env*)"
            "Read(.env*)"
            "Read(*.key)"
            "Read(*.pem)"
            "Read(**/credentials.json)"
            "Read(${homeDirectory}/.ssh/**)"
          ];
        };
      };
    };

    git.ignores = [
      ".claude/"
      "CLAUDE.local.md"
    ];

    zsh.shellAliases =
      let
        pkg = lib.getExe pkgs.claude-code;
      in
      {
        cl = pkg;
        clr = "${pkg} --resume";
      };
  };
}
