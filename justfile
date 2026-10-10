alias a := apply
alias c := check-fast
alias u := update

device := "flint-2"

fast-build := "nix-fast-build" + \
    " --skip-cached" + \
    " --systems 'x86_64-linux aarch64-linux'" + \
    " --option cores 4" + \
    " -j 4"
toplevels := "configs: builtins.mapAttrs (_: c: c.config.system.build.toplevel) configs"

apply action='switch':
    nh os {{ action }} .

check-fast:
    nix flake check

check-full:
    {{ fast-build }} --flake '.#nixosConfigurations' --select '{{ toplevels }}'
    # openwrt images stop evaluating whenever upstream's package index goes stale
    # {{ fast-build }} --flake '.#packages.x86_64-linux'
    {{ fast-build }} --flake '.#devShells.x86_64-linux'

update input="":
    nix flake update {{ input }}

upgrade:
    #!/usr/bin/env bash
    set -euEo pipefail

    # Ask for password upfront
    sudo -v
    # Keep-alive: update existing sudo timestamp until script finishes
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    trap 'git checkout HEAD -- flake.lock' ERR

    just update
    git add flake.lock
    just check-full
    just apply boot

    trap - ERR
    git commit -m "chore(flake): update inputs"

# NOTE: The target needs to already be on the tailnet.
deploy hostname action='boot':
    nh os {{ action }} . --hostname {{ hostname }} --target-host {{ hostname }}-root

build-openwrt-image:
    nom build .#{{ device }}-image --no-link --print-out-paths

deploy-openwrt *args:
    nix run .#{{ device }}-deploy -- {{ args }}

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
