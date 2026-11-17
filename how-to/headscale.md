# How to [headscale](https://headscale.net)

The control server runs on the host named by `controlServer` in [`flake.nix`](../flake.nix), behind Caddy. Caddy passes on only the paths clients need; the allowlist is in the host's `default.nix`. Headplane and the AdGuard Home UI answer only on the headnet. The embedded DERP relay serves only this headnet's devices; its STUN port is open in the `headscale` NSG in [`modules/terranix/oci.nix`](../modules/terranix/oci.nix).

```sh
host=<controlServer>
domain=<domain>
```

## Bootstrapping

1. Caddy needs a DNS token for its TLS certificate, as `cloudflare_dns_token` in [`secrets/dns.yaml`](../secrets/dns.yaml); see [infra](./infra.md). The Noise private key, the server's identity towards clients, goes in [`secrets/headscale.yaml`](../secrets/headscale.yaml):

   ```sh
   key=$(nix shell nixpkgs#headscale -c headscale generate private-key)
   sops set secrets/headscale.yaml '["headscale_noise_private_key"]' "\"$key\""
   ```

2. Apply the infra, then deploy the host. The host deploy also creates the user.

   ```sh
   just tf apply
   just nixos deploy $host switch
   ```

3. Join the control server itself, then approve it with the auth id from the `/register/<auth-id>` URL it prints.

   > [!NOTE]
   > Without `--accept-dns=false`: headscale may fail to start if its host resolves through the headnet.

   ```sh
   ssh $host-root "tailscale up --login-server https://headscale.$domain --advertise-tags=tag:control --accept-dns=false"
   # In another terminal
   ssh $host-root 'headscale auth register --auth-id <auth-id> --user <username>'
   ```

4. Put the host's headnet IP (`ssh $host-root 'tailscale ip -4'`) in its `addresses.headnet`, then `just tf apply` again; the Headplane and AdGuard Home records point at it.

## Add a user

Headscale creates a user at their first login through Pocket ID, so give them a Pocket ID account.

## Add a device

Devices that log in through Pocket ID belong to that user and expire after 180 days; servers get `tag:server` and never expire.

> [!NOTE]
> Headscale hands out IPs in join order.

### With Pocket ID

On Linux, `tailscale up --login-server https://headscale.$domain`. On [Android](https://headscale.net/stable/usage/connect/android/), [iOS and macOS](https://headscale.net/stable/usage/connect/apple/) or [Windows](https://headscale.net/stable/usage/connect/windows/), set `https://headscale.$domain` as the custom server in the app. The login opens Pocket ID; after signing in, confirm the device, and it joins as your user.

### With a pre-auth key

For a server, create a pre-auth key with its tag, then use it on the device.

```sh
# on the control server
ssh $host-root 'headscale preauthkeys create --tags tag:server'

# on the device
tailscale up --login-server https://headscale.$domain --auth-key <key>
```

## Rename a device

iOS devices by default join as `localhost`. To rename a device:

```sh
ssh $host-root 'headscale nodes rename -i <node-id> <name>'
```

## Headplane

Open `https://headplane.$domain` from a device on the headnet and log in with an API key. It can do most things except change policy; that is owned by nix. The key lives in the password manager, not in sops; a new headscale database needs a new key.

```sh
ssh $host-root 'headscale apikeys create --expiration 90d'
```

## Restore

The systemd oneshot `headscale-restore` (in [`targets/nixos/sentinel/default.nix`](../targets/nixos/sentinel/default.nix)) restores a missing database before headscale starts, so a new host needs nothing. To roll back to an earlier point (up to 7 days), as root on the control server:

```sh
# 1. Stop both services and move the current state aside.
systemctl stop headscale litestream
mv /var/lib/headscale /var/lib/headscale.old
# 2. Export Litestream's keys into the shell.
set -a; . /run/secrets/rendered/litestream_env; set +a
# 3. Restore to a point in time; e.g. 2026-11-14T00:00:00Z.
litestream restore -timestamp <time> -o /var/lib/headscale/db.sqlite /var/lib/headscale/db.sqlite
chown -R headscale:headscale /var/lib/headscale
# 4. Start headscale; it pulls in Litestream and headplane.
systemctl start headscale
```
