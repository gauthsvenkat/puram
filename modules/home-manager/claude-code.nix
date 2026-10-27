{
  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) homeDirectory;
in
{
  programs = {
    claude-code = {
      enable = true;

      context = ../../assets/configs/AGENTS.md;

      mcpServers.context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
      };

      settings = {
        env.DISABLE_TELEMETRY = "1";
        autoMemoryEnabled = false;
        theme = "dark";
        editorMode = "vim";
        cleanupPeriodDays = 7;
        includeCoAuthoredBy = false;

        permissions = {
          defaultMode = "auto";

          deny = [
            "Read(**/.env*)"
            "Edit(**/.env*)"
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
        clm = "${pkg} --model";
      };
  };
}
