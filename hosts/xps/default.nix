{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../../bases/nixos/desktop-environment/kde.nix

    ../../bases/nixos/flavor/laptop.nix

    ../../components/config.nix

    ../../components/nixos/extra/autologin.nix

    ./hardware-configuration.nix
  ];

  hostCfg = {
    hostname = "xps";
    username = "gautham";
    gitEmail = "gautham@dexterenergy.ai";
    isLaptop = true;
    wallpaper = "neon_shallows.png";
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
