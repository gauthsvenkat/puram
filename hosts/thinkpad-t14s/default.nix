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
    ../../bases/nixos/desktop-environment/niri.nix
    ../../bases/nixos/flavor/laptop.nix
    ./disko-config.nix
    ./hardware-configuration.nix
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
      glab
      go-task
      hurl
      k9s
      kubectx
      kubernetes-helm
      nodejs
      slack
      terraform
      tflint
      thunderbird
      vault

      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
    ];

    programs.starship.settings.gcloud.disabled = true;

    services.shikane = {
      enable = true;
      settings.profile = [
        {
          name = "lg-ultrawide";
          output = [
            {
              enable = true;
              mode = "best";
              position = "0,0";
              scale = 1.0;
              search = "s=0x00000000";
            }
            {
              enable = true;
              position = "952,1440";
              scale = 1.25;
              search = "n=eDP-1";
            }
          ];
        }
        {
          name = "samsung";
          output = [
            {
              enable = true;
              mode = "best";
              position = "0,0";
              scale = 1.0;
              search = "s=H000000000";
            }
            {
              enable = true;
              position = "2560,330";
              scale = 1.25;
              search = "n=eDP-1";
            }
          ];
        }
        {
          name = "undocked";
          output = [
            {
              enable = true;
              position = "0,0";
              scale = 1.25;
              search = "n=eDP-1";
            }
          ];
        }
      ];
    };
  };
}
