set working-directory := '..'

edit name="homeserver":
    sops edit secrets/{{ name }}.yaml

view name="homeserver":
    sops decrypt secrets/{{ name }}.yaml

rekey:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in secrets/*.yaml; do sops updatekeys --yes "$f"; done
