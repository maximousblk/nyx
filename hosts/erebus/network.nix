{ ... }: {
  topology.networks.incus = {
    name = "Incus";
    cidrv4 = "10.77.0.0/24";
    style = {
      primaryColor = "#c4b5fd";
      secondaryColor = null;
      pattern = "dotted";
    };
  };

  topology.self = {
    name = "erebus";
    hardware.info = "Raspberry Pi 4 Incus host";
    deviceIcon = "devices.cloud-server";
    interfaces.tailscale0 = {
      type = "tun";
      network = "tailscale";
      virtual = true;
      addresses = [ "100.100.2.5" ];
    };
    interfaces.end0 = {
      type = "ethernet";
      network = "nyx";
      addresses = [ "DHCP" ];
      physicalConnections = [
        {
          node = "sg1008d";
          interface = "lan3";
        }
      ];
    };
    interfaces.incusbr0 = {
      type = "bridge";
      network = "incus";
      virtual = true;
      addresses = [ "10.77.0.1/24" ];
    };
  };

  networking = {
    hostName = "erebus";
    wireless.enable = false;
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      extraSetFlags = [
        "--auto-update=false"
        "--ssh=false"
        "--report-posture"
      ];
    };
  };

  systemd.network.networks."10-ethernet" = {
    matchConfig.Name = "end0 eth0";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.wait-online.extraArgs = [ "--interface=end0" ];
}
