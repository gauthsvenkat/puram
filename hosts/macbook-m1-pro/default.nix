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

    programs.mcp.servers = {
      atlassian.url = "https://mcp.atlassian.com/v1/mcp";
      notion.url = "https://mcp.notion.com/mcp";
    };
  };
}
