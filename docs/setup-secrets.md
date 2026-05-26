# Secrets: sops-nix bootstrap

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) for managing the encrypted [`secrets.yaml`](../secrets.yaml). Age keys are derived from each host's SSH key - once a host's SSH key exists, the same key both decrypts secrets at activation and identifies the host in [`.sops.yaml`](../.sops.yaml).

## Enrolling a new host

1. **Generate the age key from the host's SSH key.**

   The age key is auto-generated at activation (see `modules/common/sops.nix`), so on a fresh host the file usually already exists at `~/.config/sops/age/keys.txt`, owned by `root`. Take ownership:

   ```sh
   sudo chown <user> ~/.config/sops/age/keys.txt
   ```

   If it doesn't exist (e.g. first-rebuild bootstrap), generate it manually:

   ```sh
   mkdir -p ~/.config/sops/age
   nix-shell -p ssh-to-age --run \
     "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
   ```

2. **Print the public age key:**

   ```sh
   nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"
   ```

3. **Add the public key to [`.sops.yaml`](../.sops.yaml):**

   - Add an entry under `keys` with a meaningful anchor (e.g. `&hostname`).
   - Reference it from the matching `creation_rules` block.

4. **Rekey existing secrets** so the new host can decrypt them:

   ```sh
   just secrets-rekey
   ```

## Why the user SSH key, not the host key

`modules/common/sops.nix` sets `sops.age.sshKeyPaths = [ "~/.ssh/id_ed25519" ]`, so enrollment must use that exact path. `sops-install-secrets` runs as root at activation and reads it regardless of file permissions - but the file has to exist *before* the first rebuild, or activation fails silently and `/run/secrets` stays empty.

## Editing secrets

```sh
just secrets-edit
```

Opens `secrets.yaml` in `$EDITOR` via `sops edit`. On save, sops re-encrypts under every key listed in `.sops.yaml`.
