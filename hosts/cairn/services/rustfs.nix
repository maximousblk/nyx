{ config, modx, ... }: {
  imports = [ modx.nixos.tailscale-services ];

  age.secrets.rustfs-environment = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      echo "RUSTFS_ACCESS_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 20)"
      echo "RUSTFS_SECRET_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 40)"
    '';
  };

  services.rustfs = {
    enable = true;
    environmentFile = config.age.secrets.rustfs-environment.path;
    settings = {
      RUSTFS_ADDRESS = "0.0.0.0:9000";
      RUSTFS_CONSOLE_ADDRESS = "0.0.0.0:9001";
      RUSTFS_CONSOLE_ENABLE = "true";
      RUSTFS_VOLUMES = "/mnt/data/rustfs";
    };
  };

  systemd.tmpfiles.settings."10-rustfs" = {
    "/mnt/data/rustfs".d = {
      mode = "0750";
      user = "rustfs";
      group = "rustfs";
    };
  };

  systemd.services.rustfs.unitConfig.RequiresMountsFor = [ "/mnt/data/rustfs" ];

  optx.tailscale.services.rustfs = {
    serve."https:443" = "http://localhost:9001";
    backends = [ "rustfs.service" ];
  };

  topology.self.services.rustfs = {
    name = "RustFS";
    info = "S3-compatible object storage";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/rustfs.svg";
      sha256 = "0fwadkbgkax2gj0vzsv6pw5l5in73sglaxl05vkqvpa73rz2kaqg";
    };
  };
}
