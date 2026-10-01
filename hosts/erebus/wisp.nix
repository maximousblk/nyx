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
    mkdir -p image/rootfs/etc/incus
    tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner -cJf "$out/wisp.tar.xz" -C image .
  '';

  systemd.services.wisp = rec {
    description = "Wisp container";
    wantedBy = [ "multi-user.target" ];
    requires = [ "incus-preseed.service" ];
    after = [ "incus-preseed.service" ];
    path = [ config.virtualisation.incus.clientPackage ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "start-wisp" ''
        incus="${config.virtualisation.incus.clientPackage}/bin/incus --force-local --project default"
        if ! $incus info wisp >/dev/null 2>&1; then
          $incus image import ${config.system.build.wispImage}/wisp.tar.xz --alias wisp --reuse
          $incus init wisp wisp --profile default --profile wisp
        fi
        $incus profile assign wisp default wisp
        $incus start wisp 2>/dev/null || $incus exec wisp -- true
      '';
      ExecStop = pkgs.writeShellScript "stop-wisp" ''
        exec ${config.virtualisation.incus.clientPackage}/bin/incus --force-local --project default stop wisp
      '';
    };
  };
}
