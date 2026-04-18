{
  config,
  common,
  lib,
  modx,
  ...
}:
let
  runtimeDir = "${common.paths.volumes}/zerobyte";
  runtimeDataDir = "${runtimeDir}/data";
  runtimeVolumesDir = "${runtimeDir}/volumes";
  runtimeRcloneDir = "${runtimeDir}/rclone";
  runtimeSshDir = "${runtimeDir}/ssh";
  runtimeCacheDir = "${runtimeDir}/restic/cache";

  storageDir = "${common.paths.data}/zerobyte";
  storageRepositoriesDir = "${storageDir}/repositories";

  containerStorageDir = "/srv/zerobyte-storage";
  containerProvisioningPath = "/var/lib/zerobyte/provisioning.json";
  port = 4096;
  organizationId = "019d8e05-2e3c-7000-a0eb-616e99014397";

  appSecretEnv = config.age.secrets.zerobyte-env-app-secret.path;
  rcloneConfig = config.age.secrets.zerobyte-rclone-conf.path;
  sftpSshPrivateKey = config.age.secrets.zerobyte-sftp-ssh-private-key.path;

  provisioningFile = builtins.toFile "zerobyte-provisioning.json" (
    builtins.toJSON {
      version = 1;
      repositories = [
        {
          delete = true;
          id = "victus-zen-default-repo";
          inherit organizationId;
          name = "Victus Zen Default";
          backend = "local";
          compressionMode = "auto";
          config = {
            backend = "local";
            path = "${containerStorageDir}/repositories/victus-zen-default";
          };
        }
        {
          id = "victus-home-repo";
          inherit organizationId;
          name = "Victus Home";
          backend = "local";
          compressionMode = "auto";
          config = {
            backend = "local";
            path = "${containerStorageDir}/repositories/victus-home";
          };
        }
      ];
      volumes = [
        {
          delete = true;
          id = "victus-zen-default-volume";
          inherit organizationId;
          name = "Victus Zen Default";
          backend = "sftp";
          config = {
            backend = "sftp";
            host = "victus.pony-clownfish.ts.net";
            port = 22;
            username = "maximousblk";
            privateKey = "file://zerobyte_sftp_ssh_private_key";
            path = "/home/maximousblk/.config/zen/default";
            skipHostKeyCheck = true;
          };
        }
        {
          id = "victus-home-volume";
          inherit organizationId;
          name = "Victus Home";
          backend = "sftp";
          config = {
            backend = "sftp";
            host = "victus.pony-clownfish.ts.net";
            port = 22;
            username = "maximousblk";
            privateKey = "file://zerobyte_sftp_ssh_private_key";
            path = "/home/maximousblk";
            skipHostKeyCheck = true;
          };
        }
      ];
    }
  );
in
{
  imports = [ modx.nixos.tailscale-services ];

  age.secrets.zerobyte-env-app-secret = {
    mode = "0400";
    generator.script =
      { pkgs, ... }:
      ''
        echo -n "APP_SECRET="
        ${pkgs.openssl}/bin/openssl rand -hex 32
      '';
  };

  age.secrets.zerobyte-rclone-conf.mode = "0400";
  age.secrets.zerobyte-sftp-ssh-private-key = {
    mode = "0400";
    generator.script =
      { pkgs, ... }:
      ''
        tmpdir=$(mktemp -d)
        trap 'rm -rf "$tmpdir"' EXIT
        ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -f "$tmpdir/key" >/dev/null
        cat "$tmpdir/key"
      '';
  };

  topology.self.services.zerobyte = {
    name = "Zerobyte";
    info = "Backup automation";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/zerobyte.svg";
      sha256 = "1pn9shc37fv0dxnv5bsk1va799z0ax389n56p6ayj4li2yv1jiys";
    };
  };

  systemd.tmpfiles.settings."10-zerobyte" = {
    "${runtimeDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${runtimeDataDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${runtimeVolumesDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${runtimeRcloneDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${runtimeSshDir}".d = {
      mode = "0700";
      user = "root";
      group = "root";
    };
    "${runtimeCacheDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };

    "${storageDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${storageRepositoriesDir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
  };

  virtualisation.oci-containers.containers.zerobyte = {
    image = "ghcr.io/nicotsx/zerobyte:v0.34.0";
    autoStart = true;

    environmentFiles = [ appSecretEnv ];
    environment = common.env // {
      BASE_URL = "https://zerobyte.pony-clownfish.ts.net";
      PROVISIONING_PATH = containerProvisioningPath;
      ZEROBYTE_DATABASE_URL = "/var/lib/zerobyte/data/zerobyte.db";
      RESTIC_PASS_FILE = "/var/lib/zerobyte/data/restic.pass";
      ZEROBYTE_REPOSITORIES_DIR = "${containerStorageDir}/repositories";
      ZEROBYTE_VOLUMES_DIR = "/var/lib/zerobyte/volumes";
      RESTIC_CACHE_DIR = "/var/lib/zerobyte/restic/cache";
      RCLONE_CONFIG_DIR = "/var/lib/zerobyte/rclone";
    };

    ports = [ "127.0.0.1:${toString port}:4096" ];
    volumes = [
      "${runtimeDir}:/var/lib/zerobyte"
      "${storageDir}:${containerStorageDir}"
      "${provisioningFile}:${containerProvisioningPath}:ro"
      "${rcloneConfig}:/var/lib/zerobyte/rclone/rclone.conf:ro"
      "${sftpSshPrivateKey}:/run/secrets/zerobyte_sftp_ssh_private_key:ro"
    ];

    extraOptions = [
      "--pull=always"
      "--cap-add=SYS_ADMIN"
      "--device=/dev/fuse:/dev/fuse"
    ];
  };

  systemd.services.docker-zerobyte.unitConfig.RequiresMountsFor = [
    runtimeDir
    storageDir
  ];

  systemd.services.docker-zerobyte.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = "5s";
  };

  optx.tailscale.services.zerobyte = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "docker-zerobyte.service" ];
  };
}
