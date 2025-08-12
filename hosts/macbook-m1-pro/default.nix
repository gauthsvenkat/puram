{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../../components/config.nix
    ../../bases/workstation-mac.nix
  ];

  hostCfg = {
    hostname = "macbook-m1-pro";
    username = "gautham";
    homeDirectory = "/Users/${username}";
    gitEmail = "gautham@dexterenergy.ai";
    isLaptop = true;
    wallpaper = "neon_shallows.png";
  };

  #NOTE: 1password refuses to open if installed from nixpkgs :(
  homebrew.casks = ["1password" "1password-cli"];

  home-manager.users.${username}.home.packages = with pkgs; [
    glab
    hurl
    k9s
    kubernetes-helm
    slack
    thunderbird

    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.kubectl
    ])
  ];
}
