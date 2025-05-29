apply action='switch':
  nh os {{ action }} .

[confirm]
upgrade:
  nix flake update
  just apply boot

check:
  nix flake check

[confirm]
nixos-install hostname ip:
  nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config \
    ./hosts/{{ hostname }}/hardware-configuration.nix \
    --flake .#{{ hostname }} \
    --target-host root@{{ ip }}

nixos-test hostname:
  nix run github:nix-community/nixos-anywhere -- \
    --flake .#{{ hostname }} \
    --vm-test

[confirm]
clean-branches:
  git checkout main
  git branch | grep -v "main" | xargs git branch -D
