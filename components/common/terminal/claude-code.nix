{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username homeDirectory;
in
{
  home-manager.users.${username} = {
    programs = {
      claude-code = {
        enable = true;

        mcpServers = {
          context7 = {
            type = "http";
            url = "https://mcp.context7.com/mcp";
          };

          memory = {
            type = "stdio";
            command = "${pkgs.writeShellScript "run-memory-server" ''
              export PATH="${pkgs.nodejs}/bin:$PATH"
              exec npx -y @modelcontextprotocol/server-memory
            ''}";
            env.MEMORY_FILE_PATH = "${homeDirectory}/.llm-memory.json";
          };
        };

        settings = {
          env.DISABLE_TELEMETRY = "1";
          theme = "dark";
          cleanupPeriodDays = 7;
          includeCoAuthoredBy = false;

          permissions = {
            defaultMode = "plan";
            deny = [
              "Read(./.env*)"
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
  };
}
