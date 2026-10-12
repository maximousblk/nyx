{
  pkgs,
  pkgx,
  servarr,
  ...
}:
let
  port = 8080;
  state_dir = "${servarr.persist}/dashbrr";
  configFile = (pkgs.formats.toml { }).generate "dashbrr.toml" {
    server.listen_addr = "127.0.0.1:${toString port}";
    database = {
      type = "sqlite";
      path = "${state_dir}/dashbrr.db";
    };
  };
in
{
  age.secrets.servarr-dashbrr-oidc-env.mode = "0400";
  users.users.dashbrr = {
    isSystemUser = true;
    group = "dashbrr";
  };
  users.groups.dashbrr = { };

  systemd.services.dashbrr = {
    description = "Dashbrr media stack dashboard";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      EnvironmentFile = "/run/agenix/servarr-dashbrr-oidc-env";
      User = "dashbrr";
      Group = "dashbrr";
      WorkingDirectory = state_dir;
      StateDirectory = "dashbrr";
      ExecStart = "${pkgx.dashbrr}/bin/dashbrr serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
    environment = {
      DASHBRR__CONFIG_PATH = toString configFile;
      DASHBRR__LISTEN_ADDR = "127.0.0.1:${toString port}";
      DASHBRR__DB_TYPE = "sqlite";
      DASHBRR__DB_PATH = "${state_dir}/dashbrr.db";
    };
  };

  systemd.tmpfiles.settings."10-servarr".${state_dir}.d = {
    mode = "0750";
    user = "dashbrr";
    group = "dashbrr";
  };

  optx.tailscale.services.dashbrr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "dashbrr.service" ];
  };

  topology.self.services.dashbrr = {
    name = "Dashbrr";
    info = "Media stack dashboard";
    icon = pkgx.topology-icons.dashbrr;
  };
}
