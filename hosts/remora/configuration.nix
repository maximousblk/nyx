{
  inputs,
  self,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  system.stateVersion = "25.11";
  networking.hostName = "remora";

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

      user.default = "ashwin_y";
    };
  };

  users.users.ashwin_y = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.ashwin_y = {
    imports = [ self.homeProfiles.umbra ];
  };
}
