data "cloudflare_zone" "gauthsvenkat_dev" {
  filter = {
    name = "gauthsvenkat.dev"
  }
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = data.cloudflare_zone.gauthsvenkat_dev.zone_id
  name    = "*.gauthsvenkat.dev"
  type    = "A"
  content = local.tailnet_ip
  proxied = false
  ttl     = 1
}

# imported 2026-08-26
import {
  to = cloudflare_dns_record.wildcard
  id = "0e5143f7efda9cf2fe586f686716b46e/10445a5a9799680bc63b661afe02250f"
}
