set working-directory := '..'

tf *args:
    mkdir -p .tofu && nix build .#infra-config -o .tofu/config.tf.json
    cd .tofu && sops exec-env ../secrets/infra.yaml 'tofu init -input=false -upgrade >/dev/null && tofu {{ args }}'
