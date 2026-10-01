{
  modx,
  pkgx,
  pkgs,
  ...
}:
{
  imports = [
    ./wisp.nix
    modx.nixos.tailscale-services
  ];

  networking.nftables.enable = true;

  topology.self.services.incus = {
    name = "Incus";
    info = "System container manager";
    icon = pkgx.topology-icons.incus;
  };

  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    preseed = {
      config = {
        "core.https_address" = ":8443";
      };
      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "10.77.0.1/24";
            "ipv4.dhcp" = "true";
            "ipv4.nat" = "true";
            "ipv6.address" = "none";
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config.source = "/var/lib/incus/storage-pools/default";
        }
      ];
      profiles = [
        {
          name = "default";
          project = "default";
          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
            eth0 = {
              type = "nic";
              name = "eth0";
              network = "incusbr0";
            };
          };
        }
        {
          name = "wisp";
          project = "default";
          config."security.nesting" = "true";
          devices = {
            tailscale = {
              type = "disk";
              pool = "default";
              source = "wisp-tailscale";
              path = "/var/lib/tailscale";
            };
            tun = {
              type = "unix-char";
              path = "/dev/net/tun";
            };
            incus = {
              type = "proxy";
              bind = "instance";
              connect = "unix:/var/lib/incus/unix.socket";
              listen = "unix:/etc/incus/unix.socket";
              mode = "0660";
              uid = "0";
              gid = "1";
            };
          };
        }
      ];
    };
  };

  networking.firewall.interfaces.incusbr0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [
      53
      67
    ];
  };

  optx.tailscale.services.incus = {
    serve."tcp:443" = "tcp://localhost:8443";
    backends = [ "incus.service" ];
  };
}
