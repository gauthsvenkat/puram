locals {
  cloudflare_account_id = "00000000000000000000000000000000"
}

resource "cloudflare_zone" "example_com" {
  account = {
    id = local.cloudflare_account_id
  }
  name = "example.com"
  type = "full"
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = cloudflare_zone.example_com.id
  name    = "*.example.com"
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
      "com.cloudflare.api.account.zone.${cloudflare_zone.example_com.id}" = "*"
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
        "com.cloudflare.api.account.zone.${cloudflare_zone.example_com.id}" = "*"
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
  id = "00000000000000000000000000000001/00000000000000000000000000000002" # zone_id/record_id
}

# imported 2026-08-27
import {
  to = cloudflare_zone.example_com
  id = "00000000000000000000000000000001" # zone_id
}
import {
  to = cloudflare_account_token.caddy_dns
  id = "00000000000000000000000000000000/00000000000000000000000000000003" # account_id/token_id
}
import {
  to = cloudflare_account_token.opentofu
  id = "00000000000000000000000000000000/00000000000000000000000000000004" # account_id/token_id
}
