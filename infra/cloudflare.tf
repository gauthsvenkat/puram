locals {
  cloudflare_account_id = "5d05105b8bc3e8b4050195862def62f3"
}

resource "cloudflare_zone" "gauthsvenkat_dev" {
  account = {
    id = local.cloudflare_account_id
  }
  name = "gauthsvenkat.dev"
  type = "full"
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = cloudflare_zone.gauthsvenkat_dev.id
  name    = "*.gauthsvenkat.dev"
  type    = "A"
  content = local.tailnet_ip
  proxied = false
  ttl     = 1
}

resource "cloudflare_account_token" "caddy_dns" {
  account_id = local.cloudflare_account_id
  name       = "caddy-acme-elitedesk"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = "4755a26eedb94da69e1066d98aa820be" }, # DNS Write
      { id = "c8fed203ed3043cba015a93ad1616f1f" }, # Zone Read
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${cloudflare_zone.gauthsvenkat_dev.id}" = "*"
    })
  }]
}

resource "cloudflare_account_token" "opentofu" {
  account_id = local.cloudflare_account_id
  name       = "opentofu-infra"

  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = "5bc3f8b21c554832afc660159ab75fa4" }, # Account API Tokens Write
      ]
      resources = jsonencode({
        "com.cloudflare.api.account.${local.cloudflare_account_id}" = "*"
      })
    },
    {
      effect = "allow"
      permission_groups = [
        { id = "4755a26eedb94da69e1066d98aa820be" }, # DNS Write
        { id = "c8fed203ed3043cba015a93ad1616f1f" }, # Zone Read
      ]
      resources = jsonencode({
        "com.cloudflare.api.account.zone.${cloudflare_zone.gauthsvenkat_dev.id}" = "*"
      })
    },
  ]

  # replacing this token must create the successor before revoking the
  # credential the apply itself is running on
  lifecycle {
    create_before_destroy = true
  }
}

# imported 2026-08-26
import {
  to = cloudflare_dns_record.wildcard
  id = "0e5143f7efda9cf2fe586f686716b46e/10445a5a9799680bc63b661afe02250f" # zone_id/record_id
}

# imported 2026-08-27
import {
  to = cloudflare_zone.gauthsvenkat_dev
  id = "0e5143f7efda9cf2fe586f686716b46e" # zone_id
}
import {
  to = cloudflare_account_token.caddy_dns
  id = "5d05105b8bc3e8b4050195862def62f3/943ee1261f2ab06ae847c858a00d5aea" # account_id/token_id
}
import {
  to = cloudflare_account_token.opentofu
  id = "5d05105b8bc3e8b4050195862def62f3/a20df74d1f12ef836cede6af20378be7" # account_id/token_id
}
