# How to [headscale](https://headscale.net)

The control server runs on the host named by `controlServer` in [`flake.nix`](../flake.nix), behind Caddy. Caddy passes on only the paths clients need; the allowlist is in the host's `default.nix`. Headplane and the AdGuard Home UI answer only on the headnet. The embedded DERP relay serves only this headnet's devices; its STUN port is open in the `headscale` NSG in [`modules/terranix/oci.nix`](../modules/terranix/oci.nix).

```sh
host=<controlServer>
domain=<domain>
```

## Bootstrapping

1. Caddy needs a DNS token for its TLS certificate, in the host's default sops file; see [infra](./infra.md). The Noise private key, the server's identity towards clients, goes in [`secrets/headscale.yaml`](../secrets/headscale.yaml):

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

The deploy only creates the host's own user. Create any other user before registering a device to it; `auth register` does not create one.

```sh
ssh $host-root 'headscale users create <username>'
```

## Add a device

Own devices get `tag:<username>`, so they never expire; servers get `tag:server`; other devices belong to a user and expire after 180 days.

> [!NOTE]
> Headscale hands out IPs in join order.

### With approval

On Linux, `tailscale up --login-server https://headscale.$domain`, optionally with `--advertise-tags=tag:<username>` for an own device or `--advertise-tags=tag:server` for a server. On [Android](https://headscale.net/stable/usage/connect/android/), [iOS and macOS](https://headscale.net/stable/usage/connect/apple/) or [Windows](https://headscale.net/stable/usage/connect/windows/), set `https://headscale.$domain` as the custom server in the app. Then approve it with the auth id it shows:

```sh
ssh $host-root 'headscale auth register --auth-id <auth-id> --user <username>'
```

### With a pre-auth key

Another option is to create a pre-auth key, then use it on the device. Phones take it in the app. A key with `--tags` makes a tagged device; use `--user <user-id>` instead for someone else's.

```sh
# on the control server
ssh $host-root 'headscale preauthkeys create --tags tag:<username>'

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
