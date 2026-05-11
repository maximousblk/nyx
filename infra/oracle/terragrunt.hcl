locals {
  r2_account_id            = "650d5b993b4af0b9da2ff9c0b1b4de02"
  ssh_authorized_keys_file = get_env("NYX_SSH_AUTHORIZED_KEYS_FILE")
  ssh_authorized_keys      = trimspace(file(local.ssh_authorized_keys_file))
}

remote_state {
  backend = "s3"

  config = {
    bucket = "maximousblk-nyx-tfstate"
    key    = "oracle/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://${local.r2_account_id}.r2.cloudflarestorage.com"
    }

    use_lockfile = true

    skip_bucket_enforced_tls           = true
    skip_bucket_public_access_blocking = true
    skip_bucket_root_access            = true
    skip_bucket_ssencryption           = true
    skip_bucket_versioning             = true
    skip_credentials_validation        = true
    skip_metadata_api_check            = true
    skip_region_validation             = true
    skip_requesting_account_id         = true
    skip_s3_checksum                   = true
    use_path_style                     = true
  }
}

inputs = {
  ssh_authorized_keys = local.ssh_authorized_keys
}
