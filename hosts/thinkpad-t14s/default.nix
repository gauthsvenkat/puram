{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../bases/laptop.nix
    ../../bases/niri.nix

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

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };

  # Reload wifi driver after resume to clear degraded rx; remove when fixed upstream:
  # https://bugzilla.kernel.org/show_bug.cgi?id=220438
  systemd.services.ath11k-resume =
    let
      modprobe = lib.getExe' pkgs.kmod "modprobe";
    in
    {
      description = "Reload ath11k wifi after resume";
      after = [ "suspend.target" ];
      serviceConfig = {
        ExecStart = [
          "${modprobe} -r ath11k_pci"
          "${modprobe} ath11k_pci"
        ];
        TimeoutSec = 30;
        Type = "oneshot";
      };
      wantedBy = [ "suspend.target" ];
    };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      glab
      go-task
      hurl
      k9s
      kubectx
      kubernetes-helm
      # Needed to build psycopg2 from source for work-api.
      libpq.pg_config
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
              search = "m=LG HDR WQHD";
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
