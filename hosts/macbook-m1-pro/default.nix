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
      "pgadmin4"
      "slack"
      "thunderbird"
    ];
  };

  home-manager.users.${username} = {
    #NOTE: Needed to link libpq.pg_config with openssl.
    home.sessionVariables.LDFLAGS = "-L${pkgs.openssl.out}/lib";

    home.packages = with pkgs; [
      glab
      go-task
      hurl
      k9s
      kubernetes-helm
      # NOTE: Needed to build psycopg2 from source for core-api
      libpq.pg_config
      nodejs
      vault

      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
    ];

    programs.claude-code.mcpServers = {
      atlassian = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp";
      };
      notion = {
        type = "http";
        url = "https://mcp.notion.com/mcp";
      };
    };
  };
}
