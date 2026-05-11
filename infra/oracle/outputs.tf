output "compartment_id" {
  value = module.compartment.compartment_id
}

output "vcn_id" {
  value = module.vcn.vcn_id
}

output "subnet_id" {
  value = module.vcn.subnet_all_attributes.main.id
}

output "scry_id" {
  value = one(module.scry.instance_id)
}

output "scry_private_ip" {
  value = one(module.scry.private_ip)
}

output "scry_public_ip" {
  value = oci_core_public_ip.scry.ip_address
}

output "scry_bootstrap_image_name" {
  value = local.scry_bootstrap_image_name
}
