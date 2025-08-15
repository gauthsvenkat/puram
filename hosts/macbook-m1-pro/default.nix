{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../../components/config.nix

    ../../bases/darwin/workstation.nix
  ];

  hostCfg = {
    hostname = "macbook-m1-pro";
    username = "gautham";
    homeDirectory = "/Users/${username}";
    gitEmail = "gautham@dexterenergy.ai";
    isLaptop = true;
    wallpaper = "neon_shallows.png";
  };

  homebrew.casks = [
    "1password"
    "1password-cli"
    "claude"
    "notion"
    "slack"
    "thunderbird"
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    glab
    hurl
    k9s
    kubernetes-helm

    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.kubectl
    ])
  ];
}
