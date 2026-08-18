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

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      _1password-cli
      _1password-gui
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

    programs.niri.settings.outputs = {
      "Samsung Electric Company LC32G5xT H000000000" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 144.0;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
      };

      "eDP-1" = {
        position = {
          x = 2560;
          y = 330;
        };
        scale = 1.25;
      };
    };
  };
}
