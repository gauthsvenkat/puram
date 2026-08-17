alias a := apply
alias c := check
alias u := update

os := os()
nh_subcommand := if os == "linux" { "os" } else if os == "macos" { "darwin" } else { error("Unsupported OS!") }

apply action='switch':
    nh {{ nh_subcommand }} {{ action }} .

check:
    nix flake check

update input="":
    nix flake update {{ input }}

upgrade:
    #!/usr/bin/env bash
    set -euo pipefail

    # Ask for password upfront
    sudo -v
    # Keep-alive: update existing sudo timestamp until script finishes
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    just update
    git add flake.lock
    just apply {{ if os() == "linux" { "boot" } else { "switch" } }} || (git checkout HEAD -- flake.lock && exit 1)
    git commit -m "chore(flake): update inputs"

# NOTE: Following recipe has some dependencies
# 1. For a `hostname` in the flake, there should be an equivalent `<hostname>-root` in `~/.ssh/config`.
# This should refer to the root user in the corresponding host.
# 2. The user running the following recipe should be public-key authenticated for the above.
# 3. The host running the following recipe should have ssh-agent enabled
deploy hostname action='boot':
    nh os {{ action }} . --hostname {{ hostname }} --target-host {{ hostname }}-root

secrets-edit:
    sops edit secrets.yaml

secrets-view:
    sops decrypt secrets.yaml

secrets-rekey:
    sops updatekeys secrets.yaml
