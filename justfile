mod nixos 'recipes/nixos.just'
mod openwrt 'recipes/openwrt.just'
mod secrets 'recipes/secrets.just'
mod terranix 'recipes/terranix.just'

alias a := nixos::apply
alias c := check
alias tf := terranix::tf

nixos-toplevels := "configs: builtins.mapAttrs (_: c: c.config.system.build.toplevel) configs"

# HACK: Filter to skip OpenWrt images. They stop evaluating whenever OpenWrt
# republishes its package index and the hashes pinned by nix-openwrt-imagebuilder
# go stale, which is quite often. See
# https://github.com/astro/nix-openwrt-imagebuilder#refreshing-hashes
skip-openwrt-image-drvs := "pkgs: builtins.removeAttrs pkgs" + \
    " (builtins.filter (name: builtins.match \".*-openwrt-image\" name != null)" + \
    " (builtins.attrNames pkgs))"

# We use `nix-fast-build` to evaluate and build all derivations in parallel.
fast-build := "nix-fast-build" + \
    " --skip-cached" + \
    " --systems 'x86_64-linux aarch64-linux'" + \
    " --option cores 4" + \
    " -j 4"

# Basically `nix flake check` but skips OpenWrt images.
@check:
    nix eval '.#nixosConfigurations' --apply '{{ nixos-toplevels }}' > /dev/null
    nix eval '.#devShells.x86_64-linux' > /dev/null
    nix eval '.#packages.x86_64-linux' --apply '{{ skip-openwrt-image-drvs }}' > /dev/null

# Build all derivations in parallel
@build-all:
    {{ fast-build }} --flake '.#nixosConfigurations' --select '{{ nixos-toplevels }}'
    {{ fast-build }} --flake '.#devShells.x86_64-linux'
    {{ fast-build }} --flake '.#packages.x86_64-linux' --select '{{ skip-openwrt-image-drvs }}'

# Update flake inputs
update input="":
    nix flake update {{ input }}

# Update flake inputs and build all derivations
upgrade:
    just update
    just build-all
    git commit -m "chore(flake): update inputs" -- flake.lock
