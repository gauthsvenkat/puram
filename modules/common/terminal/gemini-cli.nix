{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username homeDirectory;
in
{
  home-manager.users.${username} = {
    programs.gemini-cli = {
      enable = true;

      settings = {
        contextFileName = "CONVENTIONS.md";
        vimMode = true;
        preferredEditor = "nvim";
        telemetry.enabled = false;
        usageStatisticsEnabled = false;

        mcpServers = {
          context7.httpUrl = "https://mcp.context7.com/mcp";

          memory = {
            command = "${pkgs.writeShellScript "run-memory-server" ''
              export PATH="${pkgs.nodejs}/bin:$PATH"
              exec npx -y @modelcontextprotocol/server-memory
            ''}";
            env.MEMORY_FILE_PATH = "${homeDirectory}/.llm-memory.json";
          };
        };
      };
    };
  };
}
