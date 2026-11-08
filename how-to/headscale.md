# How to [headscale](https://headscale.net)

The control server runs on the host named by `controlServer` in [`flake.nix`](../flake.nix), behind Caddy. It is exposed to the internet, so it sits alone in the router's `headscale` zone on `lan1`, cut off from the rest of the network. The router forwards WAN 443 to it.

```sh
host=<controlServer>
domain=<domain>
```

## Bootstrapping

1. Caddy needs a DNS token for its TLS certificate, in [`secrets/headscale.yaml`](../secrets/headscale.yaml); see [infra](./infra.md).
2. Wire the host to `lan1`.
3. Deploy the router, from wifi or `lan3`–`lan5`, then the host. The host deploy also creates the user.

   ```sh
   just openwrt deploy
   just nixos deploy $host switch
   ```

4. Join the host itself, then approve it with the auth id from the `/register/<auth-id>` URL it prints:

   ```sh
   ssh $host-root "tailscale up --login-server https://headscale.$domain --advertise-tags=tag:control"
   ssh $host-root 'headscale auth register --auth-id <auth-id> --user <username>'
   ```

## Add a user

The deploy only creates the host's own user. Create any other user before registering a device to it; `auth register` does not create one.

```sh
ssh $host-root 'headscale users create <username>'
```

## Add a device

Own devices get `tag:<username>`, so they never expire; other devices belong to a user and expire after 180 days.

### With approval

On Linux, `tailscale up --login-server https://headscale.$domain`, with `--advertise-tags=tag:<username>` for an own device. On [Android](https://headscale.net/stable/usage/connect/android/), [iOS and macOS](https://headscale.net/stable/usage/connect/apple/) or [Windows](https://headscale.net/stable/usage/connect/windows/), set `https://headscale.$domain` as the custom server in the app. Then approve it with the auth id it shows:

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

iOS devices by default join as `localhost`.

```sh
ssh $host-root 'headscale nodes rename -i <node-id> <name>'
```
