set working-directory := '..'

tf *args:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p .tofu
    nix build .#infra-config -o .tofu/config.tf.json
    cd .tofu
    sops exec-env ../secrets/tofu.yaml \
      'tofu init -input=false -upgrade >/dev/null && tofu {{ args }}'
