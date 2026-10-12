{ servarr, ... }: {
  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:2";
    volumes = [ "${servarr.state_dir}/cleanuparr:/config" ];
    environment = {
      PORT = "11011";
      BIND_ADDRESS = "127.0.0.1";
      TZ = "Etc/UTC";
      DATABASE_PROVIDER = "sqlite";
    };
    extraOptions = [ "--network=host" ];
  };

  systemd.tmpfiles.settings."10-servarr"."${servarr.state_dir}/cleanuparr".d = {
    mode = "0700";
    user = "root";
    group = "root";
  };

  optx.tailscale.services.cleanuparr = {
    serve."https:443" = "http://localhost:11011";
    backends = [ "podman-cleanuparr.service" ];
  };
}
