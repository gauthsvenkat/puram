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

      mcpServers.context7.httpUrl = "https://mcp.context7.com/mcp";
    };
  };
}
