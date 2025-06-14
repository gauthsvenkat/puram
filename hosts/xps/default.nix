{
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/workstation-kde.nix
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [username];
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
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

    programs.git.userEmail = lib.mkForce "gautham@dexterenergy.ai";

    xdg.autostart.entries = [
      "${pkgs.slack}/share/applications/slack.desktop"
      "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
    ];
  };
}
