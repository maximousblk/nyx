module "compartment" {
  source  = "oracle-terraform-modules/iam/oci//modules/iam-compartment"
  version = "~> 2"

  tenancy_ocid            = var.tenancy_ocid
  compartment_id          = local.parent_compartment_id
  compartment_name        = local.project_name
  compartment_description = "managed by opentofu"
  enable_delete           = true
}

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "~> 3"

  compartment_id           = module.compartment.compartment_id
  label_prefix             = local.project_name
  freeform_tags            = local.common_tags
  create_internet_gateway  = true
  lockdown_default_seclist = true
  vcn_cidrs                = ["10.42.0.0/16"]
  vcn_dns_label            = local.project_name
  vcn_name                 = "vcn"
  enable_ipv6              = true
}

module "scry" {
  source  = "oracle-terraform-modules/compute-instance/oci"
  version = "~> 2"

  compartment_ocid            = module.compartment.compartment_id
  freeform_tags               = merge(local.common_tags, { host = local.scry_name })
  ad_number                   = local.scry_ad_number
  instance_display_name       = local.scry_name
  shape                       = local.scry_shape
  instance_flex_ocpus         = local.scry_ocpus
  instance_flex_memory_in_gbs = local.scry_memory_in_gbs
  source_ocid                 = local.scry_bootstrap_image_id
  source_type                 = "image"
  ssh_public_keys             = var.ssh_authorized_keys
  hostname_label              = local.scry_name
  public_ip                   = "EPHEMERAL"
  subnet_ocids                = [oci_core_subnet.celest_main.id]
  primary_vnic_nsg_ids        = [oci_core_network_security_group.scry.id]
  boot_volume_size_in_gbs     = local.scry_boot_volume_gbs
  block_storage_sizes_in_gbs  = []
}
