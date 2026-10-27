{ servarr, ... }: {
  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:2.10.12";
    volumes = [ "${servarr.state_dir}/cleanuparr:/config" ];
    # OIDC issuer is a MagicDNS name; localhost DNS cannot resolve it.
    extraOptions = [
      "--network=host"
      "--dns=100.100.100.100"
    ];
    environment = {
      PORT = "11011";
      BIND_ADDRESS = "127.0.0.1";
      TZ = "Etc/UTC";
      DATABASE_PROVIDER = "sqlite";
    };
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
