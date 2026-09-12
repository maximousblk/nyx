{
  inputs,
  self,
  config,
  pkgs,
  lib,
  modx,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    modx.nixos.windows-files
  ];

  system.stateVersion = "25.11";
  networking.hostName = "remora";
  documentation.man.cache.enable = false;

  topology =

    {
      nodes.apex = config.lib.topology.mkDevice "apex" {
        deviceIcon = "devices.laptop";
        hardware.info = "Intel Core Ultra X7 358H, 64GB RAM, MSI Prestige 14 Flip AI+";
        interfaceGroups = [
          [ "Wi-Fi" ]
          [ "tailscale0" ]
          [ "wsl" ]
        ];
        interfaces."Wi-Fi" = {
          type = "wifi";
          network = "nyx";
          addresses = [ "DHCP" ];
          physicalConnections = [
            {
              node = "ap";
              interface = "wifi";
            }
          ];
        };
        interfaces.tailscale0 = {
          network = "tailscale";
          type = "tun";
          virtual = true;
          addresses = [ "100.100.3.3" ];
        };
        interfaces.wsl = {
          type = "ethernet";
          network = "wsl";
          virtual = true;
        };
      };

      self = {
        parent = "apex";
        guestType = "wsl";
        interfaces.eth0 = {
          type = "ethernet";
          network = "wsl";
          virtual = true;
        };
      };
    };

  wsl = {
    enable = true;
    useWindowsDriver = true;
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

  # GPU/Vulkan support via WSL2 GPU paravirtualization
  hardware.graphics.enable = true;
  environment.sessionVariables = {
    LD_LIBRARY_PATH = [
      "/run/opengl-driver/lib"
      "${pkgs.openssl.out}/lib"
    ];
    GALLIUM_DRIVER = "d3d12";
  };

  hardware.graphics.extraPackages = with pkgs; [
    mesa
    vulkan-loader
    intel-media-driver
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      llvmPackages.openmp
      openssl
    ];
  };

  home-manager.users.${config.wsl.defaultUser} = {
    imports = [
      (self.homeProfiles.umbra {
        username = config.wsl.defaultUser;
        homeDirectory = "/home/${config.wsl.defaultUser}";
        containerHost = "unix:///var/run/docker.sock";
      })
    ];
  };
  windowsFiles."/mnt/c/Users/ashwin_y/.wslconfig".text = pkgs.writeText "wslconfig" (
    lib.generators.toINI { } {
      wsl2 = {
        kernel = ''C:\\Users\\ashwin_y\\.wsl\\bzImage-x64v3'';
        kernelModules = ''C:\\Users\\ashwin_y\\.wsl\\bzImage-x64v3-addons.vhdx'';
        networkingMode = "mirrored";
        firewall = false;
        autoProxy = false;
        dnsTunneling = true;
      };
      experimental = {
        bestEffortDnsParsing = true;
        hostAddressLoopback = true;
        initialAutoProxyTimeout = 10000;
        sparseVhd = true;
      };
    }
  );

  windowsFiles."/mnt/c/Users/ashwin_y/.wslgconfig".text = pkgs.writeText "wslgconfig" (
    lib.generators.toINI { } {
      "system-distro-env" = {
        WESTON_RDP_FRACTIONAL_HI_DPI_SCALING = true;
        WESTON_RDP_FRACTIONAL_HI_DPI_SCALING_ROUNDUP = true;
        WESTON_RDP_DEBUG_DESKTOP_SCALING_FACTOR = 175;
      };
    }
  );

}
