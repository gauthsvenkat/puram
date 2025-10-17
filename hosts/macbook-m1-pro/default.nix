{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../bases/darwin/workstation.nix
  ];

  homebrew = {
    brews = [ "libomp" ];
    casks = [
      "1password"
      "1password-cli"
      "claude"
      "notion"
      "slack"
      "thunderbird"
    ];
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      glab
      hurl
      k9s
      kubernetes-helm
      vault

      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
    ];

    programs.claude-code.mcpServers = {
      atlassian = {
        type = "sse";
        url = "https://mcp.atlassian.com/v1/sse";
      };

      notion = {
        type = "http";
        url = "https://mcp.notion.com/mcp";
      };
    };

    programs.gemini-cli.settings.mcpServers = {
      atlassian.url = "https://mcp.atlassian.com/v1/sse";
      notion.httpUrl = "https://mcp.notion.com/mcp";
    };
  };
}
