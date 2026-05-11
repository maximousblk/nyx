variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID."
}

variable "user_ocid" {
  type        = string
  description = "User OCID."
}

variable "fingerprint" {
  type        = string
  description = "API key fingerprint."
}

variable "private_key_path" {
  type        = string
  description = "Path to the API signing key."
}

variable "region" {
  type        = string
  description = "OCI region."
}

variable "parent_compartment_ocid" {
  type        = string
  default     = ""
  description = "Parent compartment. Defaults to tenancy root."
}

variable "ssh_authorized_keys" {
  type        = string
  description = "SSH public keys for the bootstrap image."
}
