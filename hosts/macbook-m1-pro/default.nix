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
    ../../bases/darwin/workstation.nix
  ];

  homebrew = {
    brews = [ "libomp" ];
    casks = [
      "1password"
      "1password-cli"
      "claude"
      "notion"
      "pgadmin4"
      "slack"
      "tailscale-app"
      "thunderbird"
    ];
  };

  home-manager.users.${username} = {
    home.sessionVariables = {
      # Lets libpq.pg_config link against openssl.
      LDFLAGS = "-L${pkgs.openssl.out}/lib";
      # For rust crates that link against libiconv (e.g. -liconv).
      LIBRARY_PATH = "${pkgs.libiconv}/lib";
    };

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
      terraform
      tflint
      vault

      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
    ];

    programs.starship.settings.gcloud.disabled = true;
  };
}
