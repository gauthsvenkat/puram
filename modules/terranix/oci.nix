{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) domain workstationKeys;
  inherit (targetCfg) alertEmail;
  inherit (targetCfg.oci) tenancyOcid;
  sentinelIp = targetCfgs.nixos."sentinel".addresses.vcn;
  stunPort = targetCfgs.nixos."sentinel".ports.headscale-stun;
in
{
  provider.oci = {
    inherit (targetCfg.oci) region;
    tenancy_ocid = tenancyOcid;
  };

  data = {
    oci_core_images."ubuntu" = {
      compartment_id = tenancyOcid;
      operating_system = "Canonical Ubuntu";
      operating_system_version = "24.04 Minimal aarch64";
      shape = "VM.Standard.A1.Flex";
      sort_by = "TIMECREATED";
      sort_order = "DESC";
    };
    oci_identity_availability_domains."main".compartment_id = tenancyOcid;
    oci_identity_domains."default" = {
      compartment_id = tenancyOcid;
      display_name = "Default";
    };

    oci_core_vnic_attachments."sentinel" = {
      compartment_id = tenancyOcid;
      instance_id = lib.tf.ref "oci_core_instance.sentinel.id";
    };
    oci_core_vnic."sentinel".vnic_id =
      lib.tf.ref "data.oci_core_vnic_attachments.sentinel.vnic_attachments[0].vnic_id";
    oci_core_private_ips."sentinel".vnic_id = lib.tf.ref "data.oci_core_vnic.sentinel.id";
  };

  resource =
    let
      idcsEndpoint = lib.tf.ref "data.oci_identity_domains.default.domains[0].url";
    in
    {
      # Auth
      # user
      oci_identity_domains_user."opentofu" = {
        idcs_endpoint = idcsEndpoint;
        user_name = "opentofu";
        schemas = [ "urn:ietf:params:scim:schemas:core:2.0:User" ];
        emails = [
          {
            type = "work";
            value = "opentofu@${domain}";
            primary = true;
          }
          {
            type = "recovery";
            value = "opentofu@${domain}";
          }
        ];
        lifecycle.ignore_changes = [ "schemas" ];
        name.family_name = "opentofu";
        urnietfparamsscimschemasoracleidcsextensioncapabilities_user.can_use_api_keys = true;
      };

      # group
      oci_identity_domains_group."opentofu" = {
        idcs_endpoint = idcsEndpoint;
        display_name = "opentofu";
        schemas = [ "urn:ietf:params:scim:schemas:core:2.0:Group" ];
        attributes = "members";
        lifecycle.ignore_changes = [ "schemas" ];
        members = [
          {
            type = "User";
            value = lib.tf.ref "oci_identity_domains_user.opentofu.id";
          }
        ];
      };

      # policy
      oci_identity_policy."opentofu" = {
        compartment_id = tenancyOcid;
        name = "opentofu";
        description = "opentofu provisioning";
        # A ref, not the literal name, so tofu creates the group before the policy.
        statements = [
          "Allow group 'Default'/'${lib.tf.ref "oci_identity_domains_group.opentofu.display_name"}' to manage all-resources in tenancy"
        ];
      };

      # api-key
      tls_private_key."oci_opentofu".algorithm = "RSA";
      oci_identity_domains_api_key."opentofu" = {
        idcs_endpoint = idcsEndpoint;
        user = {
          ocid = lib.tf.ref "oci_identity_domains_user.opentofu.ocid";
          value = lib.tf.ref "oci_identity_domains_user.opentofu.id";
        };
        schemas = [ "urn:ietf:params:scim:schemas:oracle:idcs:apikey" ];
        key = lib.tf.ref "chomp(tls_private_key.oci_opentofu.public_key_pem)";
        lifecycle.create_before_destroy = true;
      };

      # Billing
      # budget
      oci_budget_budget."main" = {
        compartment_id = tenancyOcid;
        display_name = "main";
        amount = 1; # €
        reset_period = "MONTHLY";
        target_type = "COMPARTMENT"; # across the whole tenancy, the root compartment.
        targets = [ tenancyOcid ];
      };
      oci_budget_alert_rule = {
        # `"forecast"` fires when Oracle predicts the spend will reach the threshold.
        "forecast" = {
          budget_id = lib.tf.ref "oci_budget_budget.main.id";
          type = "FORECAST";
          recipients = alertEmail;
          threshold = 100;
          threshold_type = "PERCENTAGE";
        };
        # `"actual"` fires when the spend has reached the threshold.
        "actual" = {
          budget_id = lib.tf.ref "oci_budget_budget.main.id";
          type = "ACTUAL";
          recipients = alertEmail;
          threshold = 100;
          threshold_type = "PERCENTAGE";
        };
      };

      # quota
      oci_limits_quota."free_tier" = {
        compartment_id = tenancyOcid;
        name = "free-tier";
        description = "Always Free amounts";
        statements =
          let
            mkQuota =
              family: quota: count:
              "set ${family} quota ${quota} to ${toString count} in tenancy";
          in
          [
            (mkQuota "block-storage" "total-storage-gb" 200)
            (mkQuota "compute-core" "standard-a1-core-count" 2)
            (mkQuota "compute-memory" "standard-a1-memory-count" 12)
            (mkQuota "vcn" "reserved-public-ip-count" 2)
          ];
      };

      # Network
      # vcn
      oci_core_vcn."main" = {
        compartment_id = tenancyOcid;
        display_name = "main";
        dns_label = "main";
        cidr_blocks = [ "10.0.0.0/16" ];
        is_ipv6enabled = true;
      };

      # internet-gateway
      oci_core_internet_gateway."main" = {
        compartment_id = tenancyOcid;
        vcn_id = lib.tf.ref "oci_core_vcn.main.id";
      };

      # route-table
      oci_core_default_route_table."main" = {
        manage_default_resource_id = lib.tf.ref "oci_core_vcn.main.default_route_table_id";
        route_rules = [
          {
            destination = "0.0.0.0/0";
            network_entity_id = lib.tf.ref "oci_core_internet_gateway.main.id";
          }
          {
            destination = "::/0";
            network_entity_id = lib.tf.ref "oci_core_internet_gateway.main.id";
          }
        ];
      };

      # subnet
      oci_core_subnet."public" = {
        compartment_id = tenancyOcid;
        vcn_id = lib.tf.ref "oci_core_vcn.main.id";
        dns_label = "public";
        cidr_block = lib.tf.ref "cidrsubnet(oci_core_vcn.main.cidr_blocks[0], 8, 0)";
        ipv6cidr_blocks = [ (lib.tf.ref "cidrsubnet(oci_core_vcn.main.ipv6cidr_blocks[0], 8, 0)") ];
      };

      # Firewall
      # security-list
      # Intentionally set empty in favor of Network Security Groups (NSGs)
      # Recommended by Oracle; https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securitylists.htm
      oci_core_default_security_list."main" = {
        manage_default_resource_id = lib.tf.ref "oci_core_vcn.main.default_security_list_id";
        egress_security_rules = [ ];
        ingress_security_rules = [ ];
      };

      # base NSG
      oci_core_network_security_group."base" = {
        compartment_id = tenancyOcid;
        vcn_id = lib.tf.ref "oci_core_vcn.main.id";
        display_name = "base";
      };

      # headscale NSG
      oci_core_network_security_group."headscale" = {
        compartment_id = tenancyOcid;
        vcn_id = lib.tf.ref "oci_core_vcn.main.id";
        display_name = "headscale";
      };
      oci_core_network_security_group_security_rule =
        let
          baseNsgId = lib.tf.ref "oci_core_network_security_group.base.id";
          headscaleNsgId = lib.tf.ref "oci_core_network_security_group.headscale.id";
        in
        {
          "base_egress_ipv4" = {
            network_security_group_id = baseNsgId;
            direction = "EGRESS";
            protocol = "all";
            destination = "0.0.0.0/0";
            destination_type = "CIDR_BLOCK";
          };
          "base_egress_ipv6" = {
            network_security_group_id = baseNsgId;
            direction = "EGRESS";
            protocol = "all";
            destination = "::/0";
            destination_type = "CIDR_BLOCK";
          };
          "base_fragmentation_needed_ipv4" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "1"; # ICMP
            source = "0.0.0.0/0";
            source_type = "CIDR_BLOCK";
            icmp_options = {
              type = 3;
              code = 4;
            };
          };
          "base_packet_too_big_ipv6" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "58"; # ICMPv6
            source = "::/0";
            source_type = "CIDR_BLOCK";
            icmp_options.type = 2;
          };
          "base_ping_ipv4" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "1"; # ICMP
            source = "0.0.0.0/0";
            source_type = "CIDR_BLOCK";
            icmp_options.type = 8;
          };
          "base_ping_ipv6" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "58"; # ICMPv6
            source = "::/0";
            source_type = "CIDR_BLOCK";
            icmp_options.type = 128;
          };
          "base_ssh_ipv4" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "6"; # TCP
            source = "0.0.0.0/0";
            source_type = "CIDR_BLOCK";
            tcp_options.destination_port_range = {
              min = 22;
              max = 22;
            };
          };
          "base_ssh_ipv6" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "6"; # TCP
            source = "::/0";
            source_type = "CIDR_BLOCK";
            tcp_options.destination_port_range = {
              min = 22;
              max = 22;
            };
          };

          # services
          "base_https_ipv4" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "6"; # TCP
            source = "0.0.0.0/0";
            source_type = "CIDR_BLOCK";
            tcp_options.destination_port_range = {
              min = 443;
              max = 443;
            };
          };
          "base_https_ipv6" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "6"; # TCP
            source = "::/0";
            source_type = "CIDR_BLOCK";
            tcp_options.destination_port_range = {
              min = 443;
              max = 443;
            };
          };

          # headscale
          "headscale_stun_ipv4" = {
            network_security_group_id = headscaleNsgId;
            direction = "INGRESS";
            protocol = "17"; # UDP
            source = "0.0.0.0/0";
            source_type = "CIDR_BLOCK";
            udp_options.destination_port_range = {
              min = stunPort;
              max = stunPort;
            };
          };
          "headscale_stun_ipv6" = {
            network_security_group_id = headscaleNsgId;
            direction = "INGRESS";
            protocol = "17"; # UDP
            source = "::/0";
            source_type = "CIDR_BLOCK";
            udp_options.destination_port_range = {
              min = stunPort;
              max = stunPort;
            };
          };
        };

      # Compute
      # sentinel
      oci_core_instance."sentinel" = {
        availability_domain = lib.tf.ref "data.oci_identity_availability_domains.main.availability_domains[0].name";
        compartment_id = tenancyOcid;
        display_name = "sentinel";
        shape = "VM.Standard.A1.Flex";
        create_vnic_details = {
          subnet_id = lib.tf.ref "oci_core_subnet.public.id";
          hostname_label = "sentinel";
          assign_ipv6ip = true;
          # No ephemeral IPv4; we assign a static one below.
          assign_public_ip = false;
          nsg_ids = [
            (lib.tf.ref "oci_core_network_security_group.base.id")
            (lib.tf.ref "oci_core_network_security_group.headscale.id")
          ];
          private_ip = sentinelIp;
        };
        metadata.ssh_authorized_keys = lib.concatLines workstationKeys;
        shape_config = {
          memory_in_gbs = 2;
          ocpus = 1;
        };
        source_details = {
          source_type = "image";
          source_id = lib.tf.ref "data.oci_core_images.ubuntu.images[0].id";
          boot_volume_size_in_gbs = 50;
        };
        # NOTE: Without `ignore_changes`, changes to `metadata.ssh_authorized_keys`
        # or `source_details` (e.g. a new image is released) may nuke the VM.
        # https://docs.oracle.com/en-us/iaas/api/#/en/iaas/latest/datatypes/UpdateInstanceDetails
        # https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/replacingbootvolume.htm
        lifecycle.ignore_changes = [
          "metadata"
          "source_details"
        ];
      };
      oci_core_public_ip."sentinel" = {
        compartment_id = tenancyOcid;
        display_name = "sentinel";
        lifetime = "RESERVED";
        private_ip_id = lib.tf.ref "data.oci_core_private_ips.sentinel.private_ips[0].id";
      };
    };

  output = {
    oci_fingerprint_tofu.value = lib.tf.ref "oci_identity_domains_api_key.opentofu.fingerprint";
    oci_private_key_tofu = {
      value = lib.tf.ref "tls_private_key.oci_opentofu.private_key_pem";
      sensitive = true;
    };
    oci_user_ocid_tofu.value = lib.tf.ref "oci_identity_domains_user.opentofu.ocid";
  };
}
