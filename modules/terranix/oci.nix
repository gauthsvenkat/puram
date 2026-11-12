{
  flakeCfg,
  targetCfg,

  lib,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg.oci) tenancyOcid;
in
{
  provider.oci = {
    inherit (targetCfg.oci) region;
    tenancy_ocid = tenancyOcid;
  };

  data.oci_identity_domains."default" = {
    compartment_id = tenancyOcid;
    display_name = "Default";
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
      oci_core_network_security_group_security_rule =
        let
          baseNsgId = lib.tf.ref "oci_core_network_security_group.base.id";
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
            protocol = "1";
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
            protocol = "58";
            source = "::/0";
            source_type = "CIDR_BLOCK";
            icmp_options = {
              type = 2;
              code = 0;
            };
          };
          "base_ssh_ipv4" = {
            network_security_group_id = baseNsgId;
            direction = "INGRESS";
            protocol = "6";
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
            protocol = "6";
            source = "::/0";
            source_type = "CIDR_BLOCK";
            tcp_options.destination_port_range = {
              min = 22;
              max = 22;
            };
          };
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
