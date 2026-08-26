locals {
  tailnet_ip = "100.64.0.1"
}

resource "tailscale_dns_configuration" "tailnet" {
  magic_dns          = true
  override_local_dns = true
  search_paths       = []

  nameservers {
    address = local.tailnet_ip
  }
  nameservers {
    address = "1.1.1.1"
  }
  nameservers {
    address = "9.9.9.9"
  }

  # API returns nameservers as an unordered set; ignore phantom reorder diffs.
  # To change the list deliberately: comment this out for one apply.
  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "tailscale_acl" "tailnet" {
  acl = file("${path.module}/tailnet-acl.hujson")
}

data "tailscale_device" "elitedesk" {
  hostname = "elitedesk"
}

resource "tailscale_device_tags" "elitedesk" {
  device_id = data.tailscale_device.elitedesk.node_id
  tags      = ["tag:server"]
}

# imported 2026-08-26
import {
  to = tailscale_dns_configuration.tailnet
  id = "dns_configuration"
}
import {
  to = tailscale_acl.tailnet
  id = "acl"
}
