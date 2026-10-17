mod nixos 'recipes/nixos.just'
mod openwrt 'recipes/openwrt.just'
mod secrets 'recipes/secrets.just'
mod terranix 'recipes/terranix.just'

alias a := nixos::apply
alias c := check-fast
alias tf := terranix::tf

fast-build := "nix-fast-build" + \
    " --skip-cached" + \
    " --systems 'x86_64-linux aarch64-linux'" + \
    " --option cores 4" + \
    " -j 4"
toplevels := "configs: builtins.mapAttrs (_: c: c.config.system.build.toplevel) configs"

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
    just update
    just check-full
    git commit -m "chore(flake): update inputs" -- flake.lock
