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
  };
}
