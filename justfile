alias a := apply
alias c := check
alias u := update

router := "flint-2"

apply action='switch':
    nh os {{ action }} .

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
    just apply boot || (git checkout HEAD -- flake.lock && exit 1)
    git commit -m "chore(flake): update inputs"

# NOTE: The target needs to already be on the tailnet.
deploy hostname action='boot':
    nh os {{ action }} . --hostname {{ hostname }} --target-host {{ hostname }}-root

build-router-image:
    nom build .#{{ router }}-image --no-link --print-out-paths

deploy-router *args:
    nix run .#{{ router }}-deploy -- {{ args }}

tf *args:
    sops exec-env secrets/infra.yaml 'tofu -chdir=infra {{ args }}'

secrets-edit name="homeserver":
    sops edit secrets/{{ name }}.yaml

secrets-view name="homeserver":
    sops decrypt secrets/{{ name }}.yaml

secrets-rekey:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in secrets/*.yaml; do sops updatekeys --yes "$f"; done
