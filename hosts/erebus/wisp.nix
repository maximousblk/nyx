{
  config,
  pkgs,
  self,
  ...
}:
{
  virtualisation.incus.preseed.storage_volumes = [
    {
      name = "wisp-tailscale";
      pool = "default";
      project = "default";
      type = "custom";
    }
  ];

  system.build.wispImage = pkgs.runCommand "wisp-image" { nativeBuildInputs = [ pkgs.xz ]; } ''
    mkdir -p image/rootfs "$out"
    tar -xJf ${
      self.nixosConfigurations.wisp.config.system.build.metadata + "/tarball/${self.nixosConfigurations.wisp.config.image.baseName}.tar.xz"
    } -C image metadata.yaml
    tar -xJf ${self.nixosConfigurations.wisp.config.system.build.tarball + "/tarball/${self.nixosConfigurations.wisp.config.image.baseName}.tar.xz"} -C image/rootfs
    tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner -cJf "$out/wisp.tar.xz" -C image .
    fingerprint=$(sha256sum "$out/wisp.tar.xz")
    echo "WISP_IMAGE=''${fingerprint%% *}" > "$out/environment"
  '';

  systemd.services.wisp = rec {
    environment = {
      INCUS_COMPOSE_ENV_FILE = "${config.system.build.wispImage}/environment";
      INCUS_COMPOSE_IMAGE_CACHE = "";
      INCUS_COMPOSE_PROJECT_NAME = "default";
      INCUS_COMPOSE_STORAGE_POOL = "default";
      INCUS_COMPOSE_FILE = (pkgs.formats.yaml { }).generate "wisp-compose.yaml" {
        name = "default";
        services.wisp = {
          container_name = "wisp";
          image = "local:wisp";

          networks.default.x-incus-compose.gateway = false;
          volumes = [ "wisp-tailscale:/var/lib/tailscale" ];
          healthcheck.disable = true;
          x-incus = {
            "boot.autostart" = "false";
            "security.privileged" = "false";
          };
          x-incus-compose.devices = {
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
              gid = "0";
            };
          };
        };
        networks.default = {
          external = true;
          name = "incusbr0";
        };
        volumes.wisp-tailscale = {
          external = true;
          name = "wisp-tailscale";
        };
      };
    };
    description = "Wisp container";
    wantedBy = [ "multi-user.target" ];
    requires = [ "incus-preseed.service" ];
    after = [ "incus-preseed.service" ];
    restartTriggers = [
      environment.INCUS_COMPOSE_FILE
      config.system.build.wispImage
    ];
    path = [
      config.virtualisation.incus.clientPackage
      pkgs.incus-compose
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = "${config.system.build.wispImage}/environment";
      ExecStartPre = pkgs.writeShellScript "ensure-wisp-image" ''
        incus="${config.virtualisation.incus.clientPackage}/bin/incus --force-local --project default"
        # Incus rejects importing an existing image fingerprint before it can apply
        # --reuse; remove it first so reactivating an unchanged generation succeeds.
        $incus image delete "$WISP_IMAGE" 2>/dev/null || true
        exec $incus image import ${config.system.build.wispImage}/wisp.tar.xz --alias local:wisp --reuse
      '';
      ExecStart = "${pkgs.incus-compose}/bin/incus-compose up --detach --pull never --recreate wisp";
      ExecStop = "${pkgs.incus-compose}/bin/incus-compose stop wisp";
    };
  };
}
