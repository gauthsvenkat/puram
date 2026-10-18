{
  # No auth key set on purpose, since auth keys expire after 90 days.
  # Manually run `tailscale up` once per host.
  services.tailscale.enable = true;
}
