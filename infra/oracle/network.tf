resource "oci_core_network_security_group" "scry" {
  compartment_id = module.compartment.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.scry_name}-nsg"
  freeform_tags  = merge(local.common_tags, { host = local.scry_name })
}

resource "oci_core_network_security_group_security_rule" "scry_ingress_tcp" {
  for_each = toset([for port in local.scry_tcp_ports : tostring(port)])

  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow TCP ${each.value} to ${local.scry_name}."

  tcp_options {
    destination_port_range {
      min = tonumber(each.value)
      max = tonumber(each.value)
    }
  }
}

resource "oci_core_network_security_group_security_rule" "scry_egress_all" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "egress all"
}

resource "oci_core_network_security_group_security_rule" "scry_ingress_icmp_echo" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "ping"

  icmp_options {
    type = 8
  }
}

resource "oci_core_network_security_group_security_rule" "scry_ingress_icmp_unreachable" {
  network_security_group_id = oci_core_network_security_group.scry.id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "PMTUD"

  icmp_options {
    type = 3
  }
}

data "oci_core_vnic_attachments" "scry" {
  compartment_id = module.compartment.compartment_id
  instance_id    = one(module.scry.instance_id)
}

data "oci_core_private_ips" "scry" {
  vnic_id = data.oci_core_vnic_attachments.scry.vnic_attachments[0].vnic_id
}

resource "oci_core_public_ip" "scry" {
  compartment_id = module.compartment.compartment_id
  display_name   = local.scry_name
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.scry.private_ips[0].id
  freeform_tags  = merge(local.common_tags, { host = local.scry_name })
}
