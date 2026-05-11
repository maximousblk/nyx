# Oracle bootstrap

OCI ARM VMs do not work reliably with the `nixos-anywhere` kexec bootstrap path. Use a
manual netboot installer flow instead.

Reference: <https://mtlynch.io/notes/nix-oracle-cloud/>

## scry flow

1. Provision the stock Ubuntu ARM VM with OpenTofu/Terragrunt.
   - SSH access is seeded through cloud-init using the repo-pinned GitHub keys file.

2. SSH into the temporary Ubuntu system.

3. Install/configure netboot.xyz from Ubuntu.

4. Reboot the VM and enter the OCI boot menu/console.

5. Boot netboot.xyz and select the NixOS 25.11 installer.

6. In the NixOS installer environment, re-authorize SSH keys for `root`.

7. Run `nixos-anywhere` against the already-booted NixOS installer, skipping its kexec
   bootstrap path.

8. After install, use normal deploy-rs updates for `.#scry`.

This is intentionally manual. Automating the one-time netboot/console interaction from
Terragrunt would add fragile bootstrap-only machinery.
