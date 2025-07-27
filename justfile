apply action='switch':
  nh os {{ action }} .

check:
  nix flake check

upgrade:
  nix flake update
  git add flake.lock
  git commit -m "system upgrade {{ datetime('%Y-%m-%d') }}"
  just apply boot

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
