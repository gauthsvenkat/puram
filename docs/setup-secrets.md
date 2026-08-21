# Secrets: sops-nix bootstrap

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) for managing the encrypted [`secrets.yaml`](../secrets.yaml). Age keys are derived from SSH keys, but the key source differs by host type:

- **Servers** use the SSH host key (`/etc/ssh/ssh_host_ed25519_key`), set in `bases/flavor/server.nix`.
- **Workstations** use the user's SSH key (`~/.ssh/id_ed25519`), set in `bases/workstation.nix`.

## Enrolling a new server

Nothing to provision on the host - openssh generates the host key at first boot, and sops-nix converts it to an age key in memory at every activation (staged only on the `/run/secrets.d` ramfs, never on disk).

1. **Get the age recipient from the host's public key** (no login required):

   ```sh
   nix-shell -p ssh-to-age --run "ssh-keyscan -t ed25519 <host> | ssh-to-age"
   ```

   Or on the host itself: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`

2. Add the recipient to `.sops.yaml` and rekey (see below).

Reinstalling a server regenerates its host key - re-enroll and rekey afterwards.

## Enrolling a new workstation

1. **Generate the age key from the user's SSH key.**

   The age key is auto-generated at activation, so on a fresh host the file usually already exists at `~/.config/sops/age/keys.txt`, owned by `root`. Take ownership:

   ```sh
   sudo chown <user> ~/.config/sops/age/keys.txt
   ```

   If it doesn't exist (e.g. first-rebuild bootstrap), generate it manually:

   ```sh
   mkdir -p ~/.config/sops/age
   nix-shell -p ssh-to-age --run \
     "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
   ```

   The SSH key has to exist *before* the first rebuild, or activation fails silently and `/run/secrets` stays empty.

2. **Print the public age key:**

   ```sh
   nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"
   ```

3. Add the recipient to `.sops.yaml` and rekey (see below).

## Adding a recipient to `.sops.yaml`

- Add an entry under `keys` with a meaningful anchor (e.g. `&hostname`).
- Reference it from the matching `creation_rules` block.
- Rekey existing secrets so the new host can decrypt them:

  ```sh
  just secrets-rekey
  ```

## Editing secrets

```sh
just secrets-edit
```

Opens `secrets.yaml` in `$EDITOR` via `sops edit`. On save, sops re-encrypts under every key listed in `.sops.yaml`.
