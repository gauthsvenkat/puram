# How to secrets

Secrets in this flake ([`secrets/`](../secrets/)) are encrypted with [sops](https://getsops.io) and managed with [sops-nix](https://github.com/Mic92/sops-nix).

Every host decrypts with its SSH key, converted to age:
  - servers with `/etc/ssh/ssh_host_ed25519_key` (the host's private key)
  - workstations with `~/.ssh/id_ed25519` (the user's private key)

## Enrolling a host

1. Get the age recipient from the SSH public key:
   - Server: `nix-shell -p ssh-to-age --run "ssh-keyscan -t ed25519 <host> | ssh-to-age"`
   - Workstation: `nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"`
2. Add it under `keys` in [`.sops.yaml`](../.sops.yaml) and to the rules for the files the host needs.
3. Run `just secrets rekey` on a workstation that can already decrypt.

## After changing secrets

A switch updates `/run/secrets`, but running services keep the old values unless they have `restartUnits`. New session variables need a re-login. In general, good to restart, especially if funky secrets issues are noticed.
