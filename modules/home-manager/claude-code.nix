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
  home.sessionVariables.CLAUDE_CONFIG_DIR = "${homeDirectory}/.claude";

  programs = {
    claude-code = {
      enable = true;

      context = ../../assets/configs/AGENTS.md;

      mcpServers.context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
      };

      settings = {
        autoMemoryEnabled = false;
        editorMode = "vim";
        env.DISABLE_TELEMETRY = "1";
        includeCoAuthoredBy = false;
        theme = "dark";

        permissions = {
          defaultMode = "auto";

          deny = [
            "Edit(**/.env*)"
            "Read(${homeDirectory}/.ssh/**)"
            "Read(**/.env*)"
            "Read(**/credentials.json)"
            "Read(*.key)"
            "Read(*.pem)"
          ];
        };

        voice = {
          enabled = true;
          autoSubmit = false;
          mode = "hold";
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
        clm = "${pkg} --model";
        clr = "${pkg} --resume";
      };
  };
}
