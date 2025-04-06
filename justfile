apply action='switch':
  nh os {{action}} .

upgrade:
  nix flake update
  just apply boot

upgrade-reboot:
  just upgrade
  reboot

test:
  nix flake check

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
