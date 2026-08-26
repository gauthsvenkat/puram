data "cloudflare_zone" "example_com" {
  filter = {
    name = "example.com"
  }
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = data.cloudflare_zone.example_com.zone_id
  name    = "*.example.com"
  type    = "A"
  content = local.tailnet_ip
  proxied = false
  ttl     = 1
}

# imported 2026-08-26
import {
  to = cloudflare_dns_record.wildcard
  id = "00000000000000000000000000000001/00000000000000000000000000000002"
}
