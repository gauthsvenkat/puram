{ pkgs, username, ... }:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix

    ../../common/boot.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/nix-settings.nix
    ../../common/gui.nix

    ../../common/development.nix
    ../../common/laptop.nix

    ../../common/services/kanata.nix
    ../../common/services/tailscale.nix
  ];

  services.fprintd.tod = {
    # NOTE: Fingerprint disabled since it is very annoying
    enable = false;
    driver = pkgs.libfprint-2-tod1-goodix;
  };

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

    programs.git.userEmail = "gautham@dexterenergy.ai";

    xdg.autostart.entries = [
      "${pkgs.slack}/share/applications/slack.desktop"
      "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
    ];
  };
}
