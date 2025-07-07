{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    home = {
      packages = [pkgs.claude-code];
      sessionVariables.DISABLE_TELEMETRY = 1;
    };

    programs = {
      git.ignores = [
        ".claude/"
        "CLAUDE.md"
      ];
    };
  };
}
