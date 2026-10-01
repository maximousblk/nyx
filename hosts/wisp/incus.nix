{ pkgs, ... }: {
  topology.self.services.incus = {
    name = "Incus client";
    info = "Manages Erebus through the proxied Incus socket";
    icon = "devices.cloud-server";
  };

  environment.etc."incus/config.yml".text = ''
    default-remote: local
    remotes:
      local:
        addr: unix:///etc/incus/unix.socket
        project: default
        protocol: incus
        public: false
  '';

  security.sudo.extraConfig = ''
    Defaults env_keep += "INCUS_SOCKET INCUS_CONF"
  '';

  environment = {
    systemPackages = [
      pkgs.bashInteractive
      pkgs.incus.client
    ];
    variables.INCUS_CONF = "/etc/incus";
    variables.INCUS_SOCKET = "/etc/incus/unix.socket";
  };
}
