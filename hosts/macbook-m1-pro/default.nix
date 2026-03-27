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

    programs.claude-code = {
      mcpServers = {
        atlassian = {
          type = "http";
          url = "https://mcp.atlassian.com/v1/mcp";
        };
        notion = {
          type = "http";
          url = "https://mcp.notion.com/mcp";
        };
      };

      settings.permissions = {
        allow = [
          # Atlassian (read-only)
          "mcp__atlassian__atlassianUserInfo"
          "mcp__atlassian__fetch"
          "mcp__atlassian__getAccessibleAtlassianResources"
          "mcp__atlassian__getConfluencePage"
          "mcp__atlassian__getConfluencePageDescendants"
          "mcp__atlassian__getConfluencePageFooterComments"
          "mcp__atlassian__getConfluencePageInlineComments"
          "mcp__atlassian__getConfluenceSpaces"
          "mcp__atlassian__getJiraIssue"
          "mcp__atlassian__getJiraIssueRemoteIssueLinks"
          "mcp__atlassian__getJiraIssueTypeMetaWithFields"
          "mcp__atlassian__getJiraProjectIssueTypesMetadata"
          "mcp__atlassian__getPagesInConfluenceSpace"
          "mcp__atlassian__getTransitionsForJiraIssue"
          "mcp__atlassian__getVisibleJiraProjectsList"
          "mcp__atlassian__lookupJiraAccountId"
          "mcp__atlassian__search"
          "mcp__atlassian__searchConfluenceUsingCql"
          "mcp__atlassian__searchJiraIssuesUsingJql"

          # Notion (read-only)
          "mcp__notion__notion-fetch"
          "mcp__notion__notion-get-comments"
          "mcp__notion__notion-get-self"
          "mcp__notion__notion-get-teams"
          "mcp__notion__notion-get-user"
          "mcp__notion__notion-get-users"
          "mcp__notion__notion-query-data-sources"
          "mcp__notion__notion-query-database-view"
          "mcp__notion__notion-search"

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
          # Atlassian (mutating)
          "mcp__atlassian__addCommentToJiraIssue"
          "mcp__atlassian__addWorklogToJiraIssue"
          "mcp__atlassian__createConfluenceFooterComment"
          "mcp__atlassian__createConfluenceInlineComment"
          "mcp__atlassian__createConfluencePage"
          "mcp__atlassian__createJiraIssue"
          "mcp__atlassian__editJiraIssue"
          "mcp__atlassian__transitionJiraIssue"
          "mcp__atlassian__updateConfluencePage"

          # Notion (mutating)
          "mcp__notion__notion-create-comment"
          "mcp__notion__notion-create-database"
          "mcp__notion__notion-create-pages"
          "mcp__notion__notion-duplicate-page"
          "mcp__notion__notion-move-pages"
          "mcp__notion__notion-update-data-source"
          "mcp__notion__notion-update-page"

          # GitLab CLI (mutating)
          "Bash(glab issue create *)"
          "Bash(glab mr approve *)"
          "Bash(glab mr create *)"
          "Bash(glab mr merge *)"
        ];
      };
    };
  };
}
