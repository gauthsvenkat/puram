{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) homeDirectory;
in
{
  programs.gemini-cli = {
    enable = true;
    settings = {
      general = {
        vimMode = true;
        preferredEditor = "nvim";
        disableAutoUpdate = true;
      };

      context.fileName = "CONVENTIONS.md";
      telemetry.enabled = false;
      privacy.usageStatisticsEnabled = false;

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
}
