locals {
  project_name = "celest"
  subnet_cidr  = "10.42.0.0/24"

  scry_name                 = "scry"
  scry_ad_number            = 1
  scry_shape                = "VM.Standard.A1.Flex"
  scry_ocpus                = 4
  scry_memory_in_gbs        = 24
  scry_boot_volume_gbs      = 200
  scry_bootstrap_image_id   = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaarcggq2ehi4fptcrkbaln6hsyhlnamwgro3o7qd3ls4e4aglmmgea"
  scry_bootstrap_image_name = "Canonical-Ubuntu-24.04-aarch64-2026.03.31-0"
  scry_tcp_ports            = [22, 80, 443]

  parent_compartment_id = var.parent_compartment_ocid != "" ? var.parent_compartment_ocid : var.tenancy_ocid
  common_tags = {
    managed-by = "opentofu"
    project    = local.project_name
  }
}
