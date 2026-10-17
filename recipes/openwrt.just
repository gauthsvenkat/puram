set working-directory := '..'

build device='flint-2':
    nom build .#{{ device }}-image --no-link --print-out-paths

deploy device='flint-2':
    nix run .#{{ device }}-deploy
