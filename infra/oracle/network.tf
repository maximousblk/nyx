// Managed directly instead of via the vcn module: subnet IPv6 CIDR fields are
// commented out in oracle-terraform-modules/terraform-oci-vcn and there's no
// way to assign one through the module.
// https://github.com/oracle-terraform-modules/terraform-oci-vcn/issues/139
resource "oci_core_subnet" "celest_main" {
  compartment_id  = module.compartment.compartment_id
  vcn_id          = module.vcn.vcn_id
  cidr_block      = local.subnet_cidr
  ipv6cidr_block  = cidrsubnet(module.vcn.vcn_all_attributes.ipv6cidr_blocks[0], 8, 0)
  display_name    = "${local.project_name}-main"
  dns_label       = "main"
  dhcp_options_id = module.vcn.vcn_all_attributes.default_dhcp_options_id
  route_table_id  = module.vcn.ig_route_id
  freeform_tags   = local.common_tags

  prohibit_public_ip_on_vnic = false

  lifecycle {
    ignore_changes = [defined_tags, dns_label, freeform_tags]
  }
}

resource "oci_core_network_security_group" "scry" {
  compartment_id = module.compartment.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.scry_name}-nsg"
  freeform_tags  = merge(local.common_tags, { host = local.scry_name })
}

resource "oci_core_network_security_group_security_rule" "scry_ingress_tcp_v6" {
  for_each = toset([for port in local.scry_tcp_ports : tostring(port)])

  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "::/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow TCP ${each.value} to ${local.scry_name}."

  tcp_options {
    destination_port_range {
      min = tonumber(each.value)
      max = tonumber(each.value)
    }
  }
}

resource "oci_core_network_security_group_security_rule" "scry_ingress_icmpv6_echo" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "INGRESS"
  protocol                  = "58"
  source                    = "::/0"
  source_type               = "CIDR_BLOCK"
  description               = "ping6"

  icmp_options {
    type = 128
  }
}

resource "oci_core_network_security_group_security_rule" "scry_ingress_icmpv6_unreachable" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "INGRESS"
  protocol                  = "58"
  source                    = "::/0"
  source_type               = "CIDR_BLOCK"
  description               = "PMTUD"

  icmp_options {
    type = 2
  }
}

resource "oci_core_network_security_group_security_rule" "scry_egress_all" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "egress all (IPv4)"
}

resource "oci_core_network_security_group_security_rule" "scry_egress_all_v6" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "::/0"
  destination_type          = "CIDR_BLOCK"
  description               = "egress all (IPv6)"
}

resource "oci_core_ipv6" "scry" {
  vnic_id       = data.oci_core_vnic_attachments.scry.vnic_attachments[0].vnic_id
  display_name  = local.scry_name
  freeform_tags = merge(local.common_tags, { host = local.scry_name })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [vnic_id]
  }
}

data "oci_core_vnic_attachments" "scry" {
  compartment_id = module.compartment.compartment_id
  instance_id    = one(module.scry.instance_id)
}

data "oci_core_vnic" "scry" {
  vnic_id = data.oci_core_vnic_attachments.scry.vnic_attachments[0].vnic_id
}
