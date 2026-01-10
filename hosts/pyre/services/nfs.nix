{ config, lib, ... }:
{
  config = {
    # NFSv4.2 server for media library
    services.nfs.server = {
      enable = true;
      nproc = 8;

      exports = ''
        # Read-only media library export
        # Tailscale network: 100.64.0.0/10
        /mnt/data/servarr/media/library 100.64.0.0/10(ro,async,no_subtree_check,all_squash,anonuid=65534,anongid=65534)
      '';
    };

    # NFSv4 only (disable v2/v3)
    boot.extraModprobeConfig = ''
      options nfsd vers2=n vers3=n vers4=y
    '';

    # Network buffer tuning for NFS (no reboot needed)
    boot.kernel.sysctl = {
      # Socket buffers - support 1MB NFS r/wsize
      "net.core.rmem_max" = 4194304; # 4MB
      "net.core.wmem_max" = 4194304; # 4MB
      "net.core.rmem_default" = 1048576; # 1MB
      "net.core.wmem_default" = 1048576; # 1MB

      # TCP buffer tuning (min, default, max)
      "net.ipv4.tcp_rmem" = "4096 1048576 4194304";
      "net.ipv4.tcp_wmem" = "4096 1048576 4194304";
    };

    # Open NFS port on Tailscale interface
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2049 ];
  };
}
