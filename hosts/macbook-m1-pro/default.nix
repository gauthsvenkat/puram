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
      "thunderbird"
    ];
  };

  home-manager.users.${username} = {
    home.sessionVariables = {
      #NOTE: Needed to link libpq.pg_config with openssl.
      LDFLAGS = "-L${pkgs.openssl.out}/lib";
      # NOTE: Needed for rust crates that link against libiconv (e.g. -liconv)
      LIBRARY_PATH = "${pkgs.libiconv}/lib";
    };

    home.packages = with pkgs; [
      glab
      go-task
      hurl
      k9s
      kubernetes-helm
      # NOTE: Needed to build psycopg2 from source for core-api
      libpq.pg_config
      nodejs
      vault

      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.kubectl
      ])
    ];

    programs.claude-code.settings.permissions = {
      allow = [
        # GitLab CLI (read-only)
        "Bash(glab ci list *)"
        "Bash(glab ci view *)"
        "Bash(glab issue list *)"
        "Bash(glab issue view *)"
        "Bash(glab mr list *)"
        "Bash(glab mr view *)"
        "Bash(glab release list *)"
        "Bash(glab release view *)"
        "Bash(glab repo view *)"
      ];

      ask = [
        # GitLab CLI (mutating)
        "Bash(glab issue create *)"
        "Bash(glab mr approve *)"
        "Bash(glab mr create *)"
        "Bash(glab mr merge *)"
      ];
    };
  };
}
