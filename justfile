apply action='switch':
  nh os {{action}} .

[confirm]
update:
  nix flake update

upgrade:
  just apply boot

test:
  nix flake check

[confirm]
nixos-install hostname ip:
  nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config \
    ./hosts/{{hostname}}/hardware-configuration.nix \
    --flake .#{{hostname}} \
    --target-host root@{{ip}}

nixos-test hostname:
  nix run github:nix-community/nixos-anywhere -- \
    --flake .#{{hostname}} \
    --vm-test

secret-rekey:
  nix run github:ryantm/agenix -- -r

secret-edit path:
  nix run github:ryantm/agenix -- -e {{path}}

[confirm]
clean-branches:
  git checkout main && git branch | grep -v "main" | xargs git branch -D
