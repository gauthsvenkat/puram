mod nixos 'recipes/nixos.just'
mod openwrt 'recipes/openwrt.just'
mod secrets 'recipes/secrets.just'
mod terranix 'recipes/terranix.just'

alias a := nixos::apply
alias c := check-fast
alias tf := terranix::tf

check-fast:
    nix flake check

fast-build := "nix-fast-build" + \
    " --skip-cached" + \
    " --systems 'x86_64-linux aarch64-linux'" + \
    " --option cores 4" + \
    " -j 4"
toplevels := "configs: builtins.mapAttrs (_: c: c.config.system.build.toplevel) configs"
no-openwrt-images := "pkgs: builtins.removeAttrs pkgs" + \
    " (builtins.filter (name: builtins.match \".*-openwrt-image\" name != null)" + \
    " (builtins.attrNames pkgs))"

check-full:
    {{ fast-build }} --flake '.#nixosConfigurations' --select '{{ toplevels }}'
    {{ fast-build }} --flake '.#devShells.x86_64-linux'
    # HACK: OpenWrt images are skipped, because they stop evaluating whenever upstream's package index goes stale.
    {{ fast-build }} --flake '.#packages.x86_64-linux' --select '{{ no-openwrt-images }}'

update input="":
    nix flake update {{ input }}

upgrade:
    just update
    just check-full
    git commit -m "chore(flake): update inputs" -- flake.lock
