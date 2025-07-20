{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/workstation-kde.nix

    ../../components/config.nix
  ];

  hostCfg = {
    hostname = "xps";
    username = "gautham";
    gitEmail = "gautham@dexterenergy.ai";
    isLaptop = true;
    wallpaper = "neon_shallows.png";
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [username];
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      glab
      hurl
      jq
      k9s
      kubernetes-helm
      slack
      thunderbird

      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
    ];

    xdg.autostart.entries = [
      "${pkgs.slack}/share/applications/slack.desktop"
      "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
    ];
  };
}
