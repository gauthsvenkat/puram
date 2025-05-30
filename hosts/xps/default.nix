{
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix

    ../../bases/laptop.nix

    ../../components/gui/kde.nix
    ../../components/cli/yakuake.nix
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      slack
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
      k9s
      kubernetes-helm
      thunderbird
      hurl
      jq
    ];

    programs.git.userEmail = lib.mkForce "gautham@dexterenergy.ai";

    xdg.autostart.entries = [
      "${pkgs.slack}/share/applications/slack.desktop"
      "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
    ];
  };
}
