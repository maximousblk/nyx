{
  inputs,
  self,
  config,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  system.stateVersion = "25.11";
  networking.hostName = "remora";

  topology =

    {
      nodes.apex = config.lib.topology.mkDevice "apex" {
        deviceIcon = "devices.laptop";
        hardware.info = "Intel Core Ultra X7 358H, 64GB RAM, MSI Prestige 14 Flip AI+";
        interfaceGroups = [
          [ "Wi-Fi" ]
          [ "tailscale0" ]
        ];
        interfaces."Wi-Fi" = {
          type = "wifi";
          network = "nyx";
          addresses = [ "DHCP" ];
          physicalConnections = [
            {
              node = "router";
              interface = "wifi";
              renderer.reverse = true;
            }
          ];
        };
        interfaces.tailscale0 = {
          network = "tailscale";
          type = "tun";
          virtual = true;
          addresses = [ "100.100.3.3" ];
        };
      };

      self = {
        parent = "apex";
        guestType = "wsl";
        interfaces.eth0 = {
          virtual = true;
        };
      };
    };

  wsl = {
    enable = true;
    defaultUser = "ashwin_y";

    wslConf = {
      automount = {
        enabled = true;
        ldconfig = false;
        mountFsTab = false;
        options = "metadata,uid=1000,gid=100";
        root = "/mnt";
      };

      boot.systemd = true;

      interop = {
        appendWindowsPath = true;
        enabled = true;
      };

      network = {
        generateHosts = true;
        generateResolvConf = true;
        hostname = "remora";
      };

      user.default = config.wsl.defaultUser;
    };
  };

  users.users.${config.wsl.defaultUser} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  home-manager.users.${config.wsl.defaultUser} = {
    imports = [
      (self.homeProfiles.mkUmbra {
        username = config.wsl.defaultUser;
        homeDirectory = "/home/${config.wsl.defaultUser}";
        containerHost = "unix:///var/run/docker.sock";
      })
    ];
  };
}
