{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) homeDirectory;
  uvx = lib.getExe' pkgs.uv "uvx";
in
{
  programs = {
    claude-code = {
      enable = true;

      memory.source = ../../../notnix/configs/CLAUDE.md;

      mcpServers = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
        };
        ref = {
          type = "http";
          url = "https://api.ref.tools/mcp";
        };
        CodeGraphContext = {
          type = "stdio";
          command = uvx;
          args = [
            "--from"
            "codegraphcontext"
            "cgc"
            "mcp"
            "start"
          ];
        };
        markitdown = {
          type = "stdio";
          command = uvx;
          args = [ "markitdown-mcp" ];
        };
      };

      settings = {
        env.DISABLE_TELEMETRY = "1";
        theme = "dark";
        cleanupPeriodDays = 7;
        includeCoAuthoredBy = false;

        permissions = {
          defaultMode = "default";

          deny = [
            "Read(*.env*)"
            "Read(*.key)"
            "Read(*.pem)"
            "Read(**/credentials.json)"
            "Read(${homeDirectory}/.ssh/**)"
          ];

          allow = [
            # File reading (deny overrides for secrets)
            "Read"

            # Read-only CLI tools
            "Bash(basename *)"
            "Bash(cat *)"
            "Bash(diff *)"
            "Bash(dirname *)"
            "Bash(du *)"
            "Bash(fd *)"
            "Bash(file *)"
            "Bash(grep *)"
            "Bash(head *)"
            "Bash(jq *)"
            "Bash(ls *)"
            "Bash(pwd)"
            "Bash(realpath *)"
            "Bash(rg *)"
            "Bash(sort *)"
            "Bash(stat *)"
            "Bash(tail *)"
            "Bash(tree *)"
            "Bash(uniq *)"
            "Bash(wc *)"
            "Bash(which *)"

            # Git (non-destructive)
            "Bash(git add *)"
            "Bash(git blame *)"
            "Bash(git branch)"
            "Bash(git branch --list *)"
            "Bash(git branch -a)"
            "Bash(git branch -v*)"
            "Bash(git describe*)"
            "Bash(git diff*)"
            "Bash(git fetch*)"
            "Bash(git log*)"
            "Bash(git ls-files*)"
            "Bash(git pull*)"
            "Bash(git remote*)"
            "Bash(git rev-parse *)"
            "Bash(git shortlog*)"
            "Bash(git show*)"
            "Bash(git stash*)"
            "Bash(git status*)"

            # GitHub CLI (read-only)
            "Bash(gh issue list *)"
            "Bash(gh issue view *)"
            "Bash(gh pr checks *)"
            "Bash(gh pr list *)"
            "Bash(gh pr view *)"
            "Bash(gh release list *)"
            "Bash(gh release view *)"
            "Bash(gh repo view *)"

            # Docker (read-only)
            "Bash(docker compose config*)"
            "Bash(docker compose logs*)"
            "Bash(docker compose ps*)"
            "Bash(docker images*)"
            "Bash(docker inspect *)"
            "Bash(docker logs *)"
            "Bash(docker network ls*)"
            "Bash(docker ps*)"
            "Bash(docker stats*)"
            "Bash(docker top *)"
            "Bash(docker volume ls*)"

            # Web
            "WebFetch(domain:discourse.nixos.org)"
            "WebFetch(domain:github.com)"
            "WebFetch(domain:gist.githubusercontent.com)"
            "WebFetch(domain:raw.githubusercontent.com)"
            "WebFetch(domain:stackoverflow.com)"
            "WebSearch"

            # MCP
            "mcp__CodeGraphContext"
            "mcp__context7"
            "mcp__markitdown"
            "mcp__ref"
          ];

          ask = [
            # Docker (mutating)
            "Bash(docker build *)"
            "Bash(docker compose down*)"
            "Bash(docker compose up*)"
            "Bash(docker exec *)"
            "Bash(docker pull *)"
            "Bash(docker push *)"
            "Bash(docker restart *)"
            "Bash(docker rm *)"
            "Bash(docker rmi *)"
            "Bash(docker run *)"
            "Bash(docker start *)"
            "Bash(docker stop *)"

            # Git (mutating)
            "Bash(git branch -D *)"
            "Bash(git branch -d *)"
            "Bash(git checkout *)"
            "Bash(git cherry-pick *)"
            "Bash(git clean *)"
            "Bash(git commit *)"
            "Bash(git merge *)"
            "Bash(git push*)"
            "Bash(git rebase *)"
            "Bash(git reset *)"
            "Bash(git restore *)"
            "Bash(git revert *)"
            "Bash(git switch *)"
            "Bash(git tag *)"
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
