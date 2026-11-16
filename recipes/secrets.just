set working-directory := '..'

edit name="homeserver":
    sops edit secrets/{{ name }}.yaml

view name="homeserver":
    sops decrypt secrets/{{ name }}.yaml

rekey:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in secrets/*.yaml; do sops updatekeys --yes "$f"; done

copy name:
    #!/usr/bin/env bash
    set -euo pipefail
    json=$(just terranix::tf output -json {{ name }})
    keys=$(jq --raw-output 'keys[]' <<<"$json")
    for key in $keys; do
      jq ".$key" <<<"$json" |
        sops set --value-stdin secrets/{{ name }}.yaml "[\"$key\"]"
    done

rotate address name: && (copy name)
    just terranix::tf apply -replace={{ address }}
