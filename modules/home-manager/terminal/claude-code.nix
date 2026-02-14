{ hostCfg, ... }:
let
  inherit (hostCfg) homeDirectory;
in
{
  programs = {
    claude-code = {
      enable = true;
      enableMcpIntegration = true;

      rules."general" = ../../../notnix/llms/rules.md;

      settings = {
        env.DISABLE_TELEMETRY = "1";
        theme = "dark";
        cleanupPeriodDays = 7;
        includeCoAuthoredBy = false;

        permissions = {
          defaultMode = "default";
          deny = [
            "Read(./.env*)"
            "Read(${homeDirectory}/.ssh/*)"
          ];
        };
      };
    };

    git.ignores = [
      ".claude/"
      "CLAUDE.local.md"
    ];
  };
}
