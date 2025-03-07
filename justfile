doit action='switch':
  nh os {{action}} .

update:
  nix flake update

upgrade: update doit

test:
  nix flake check

install-nixos hostname ip:
  nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config \
    .hosts/{{hostname}}/hardware-configuration.nix \
    --flake .#{{hostname}} \
    --target-host root@{{ip}}

test-nixos hostname:
  nix run github:nix-community/nixos-anywhere -- \
    --flake .#{{hostname}} \
    --vm-test
