{
  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  imports = [
    ../../../bases/nixos/laptop.nix
    ../../../bases/nixos/niri.nix

    ./disko-config.nix
    ./hardware-configuration.nix
    ./monitors.nix
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

  # Resume after sleep degrades rx in wifi driver.
  # HACK: Reload wifi driver after resume to clear degraded rx.
  # remove when fixed upstream: https://bugzilla.kernel.org/show_bug.cgi?id=220438
  systemd.services."ath11k-resume" =
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

    programs = {
      firefox.policies = {
        Bookmarks =
          let
            mkToolbar = Title: URL: {
              inherit Title URL;
              Placement = "toolbar";
            };
          in
          lib.mkAfter [
            (mkToolbar "GitLab" "https://gitlab.com/")
            (mkToolbar "Vault" "https://vault.work.example/ui/")
            (mkToolbar "Jira" "https://work.atlassian.net/jira/software/projects/WORK/boards/1")
            (mkToolbar "ArgoCD" "https://argocd.work.example/applications?proj=work-services")
            (mkToolbar "Cloud console" "https://console.cloud.google.com/welcome?project=work-project")
          ];

        ExtensionSettings."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      starship.settings.gcloud.disabled = true;
    };
  };
}
