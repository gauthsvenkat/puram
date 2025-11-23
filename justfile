alias a := apply
alias c := check
alias u := update

os := os()
nh_subcommand := if os == "linux" { "os" } else if os == "macos" { "darwin" } else { error("Unsupported OS!") }

apply action='switch':
    nh {{ nh_subcommand }} {{ action }} .

check:
    nix flake check

update input="":
    nix flake update {{ input }}

upgrade:
    just update
    git add flake.lock
    just apply {{ if os() == "linux" { "boot" } else { "switch" } }} || (git checkout HEAD -- flake.lock && exit 1)
    git commit -m "chore(flake): update inputs"

# NOTE: Following recipe has some dependencies
# 1. For a `hostname` in the flake, there should be an equivalent `<hostname>-root` in `~/.ssh/config`.
# This should refer to the root user in the corresponding host.
# 2. The user running the following recipe should be public-key authenticated for the above.
# 3. The host running the following recipe should have ssh-agent enabled
deploy hostname action='boot':
    nh os {{ action }} . --hostname {{ hostname }} --target-host {{ hostname }}-root --build-host localhost

secrets-edit:
    sops edit secrets.yaml

secrets-view:
    sops decrypt secrets.yaml

secrets-rekey:
    sops updatekeys secrets.yaml

[confirm]
nixos-install hostname ip:
    nix run github:nix-community/nixos-anywhere -- \
      --generate-hardware-config nixos-generate-config \
      ./hosts/{{ hostname }}/hardware-configuration.nix \
      --flake .#{{ hostname }} \
      --target-host root@{{ ip }}

[confirm]
nixos-test hostname:
    nix run github:nix-community/nixos-anywhere -- \
      --flake .#{{ hostname }} \
      --vm-test
