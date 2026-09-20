{ pkgs, ... }: {
  topology.self = {
    name = "Wisp";
    hardware.info = "Incus management guest";
    guestType = "incus-container";
    parent = "erebus";
    interfaces.tailscale0 = {
      type = "tun";
      network = "tailscale";
      virtual = true;
    };
  };

  networking = {
    hostName = "wisp";
    useHostResolvConf = false;
    useNetworkd = true;
  };

  services.resolved.enable = true;

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        AllowAgentForwarding = true;
        AllowTcpForwarding = true;
        PermitTunnel = true;
        X11Forwarding = false;
      };
    };

    tailscale = {
      enable = true;
      extraSetFlags = [
        "--auto-update=false"
        "--ssh"
      ];
    };
  };

  environment.systemPackages = [
    pkgs.openssh
    pkgs.tailscale
  ];

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig.DHCP = "ipv4";
    };
  };
}
