set working-directory := '..'

build device='flint-2':
    nom build .#{{ device }}-openwrt-image --no-link --print-out-paths

deploy device='flint-2' action='reload':
    nix run .#{{ device }}-deploy -- {{ if action == "reload" { "--reload" } else if action == "reboot" { "" } else { error("action must be reload or reboot") } }}
