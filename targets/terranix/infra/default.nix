{
  imports = [
    ../../../bases/terranix/opentofu.nix

    ../../../modules/terranix/cloudflare.nix
    ../../../modules/terranix/scaleway.nix
    ../../../modules/terranix/tailscale.nix
  ];
}
