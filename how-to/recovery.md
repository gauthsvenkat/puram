# How to recover

## Control server

The control server (`servers.control` in [`flake.nix`](../flake.nix)) runs Pocket ID and headscale. Litestream replicates their databases to Scaleway, and each service restores its database before it starts if the database is missing ([`backups.nix`](../targets/nixos/sentinel/backups.nix)). The tofu state is in [`secrets/`](../secrets/), so it survives the host.

Recover from a device off the headnet (`tailscale down`); headnet DNS goes through the control server.

```sh
host=<servers.control>
domain=<domain>
```

1. Move the host to the new provider:
   - Add it to [`modules/terranix/`](../modules/terranix/) and point the control server's records in [`cloudflare.nix`](../modules/terranix/cloudflare.nix) at it. Its firewall should open only 22, 443 and the STUN port (like the `headscale` NSG in [`oci.nix`](../modules/terranix/oci.nix)).
   - Replace the provider's base, `system` and disk in [`targets/nixos/sentinel/`](../targets/nixos/sentinel/) accordingly.
   - Update the domain in [`aliases.nix`](../modules/nixos/ssh/aliases.nix), then `switch` the current workstation.

   Pocket ID is not running yet, so the `pocketid` provider can't refresh; apply only the host and its records:

   ```sh
   just tf apply -target=<resource> ...
   ```

2. [Install NixOS](./nixos.md#installing) on it. Hosts decrypt secrets with their SSH host key; the old one is gone with the old host. So, generate a new one, enroll it and update `sshHostKey` in its `targetCfg.nix`.

3. Deploy. Pocket ID and headscale restore their databases from Scaleway.

   > [!NOTE]
   > If the host keeps its name, drop the old key from `~/.ssh/known_hosts` with `ssh-keygen -R <name>`.

   ```sh
   just nixos deploy $host switch
   ```

4. The restored headscale database still has the old control server node at `addresses.headnet`. Delete it, then join the new host as in [headscale bootstrapping](./headscale.md#bootstrapping) step 3, with `tag:dns` too, as the control server is also `servers.dns`.

   ```sh
   ssh $host-root 'headscale nodes list'
   ssh $host-root 'headscale nodes delete --force -i <node-id>'
   key=$(ssh $host-root 'headscale preauthkeys create --tags tag:control,tag:dns')
   ssh $host-root "tailscale up --login-server https://headscale.$domain --auth-key $key --accept-dns=false"
   ```

   Set `addresses.headnet` in its `targetCfg.nix` to `ssh $host-root 'tailscale ip -4'`, then deploy again.

   ```sh
   just nixos deploy $host switch
   ```

5. Apply the rest of the infra. The Pocket ID resources should show no changes, as the restored database matches the state.

   ```sh
   just tf apply
   ```
