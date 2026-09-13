{
  inputs,
  modx,
  pkgs,
  ...
}:
let
  omp = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
in
{
  imports = [ modx.nixos.tailscale-services ];

  systemd.services = {
    omp-auth-broker = {
      description = "OMP auth broker";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "maximousblk";
        Group = "users";
        StateDirectory = "omp-auth";
        WorkingDirectory = "/var/lib/omp-auth";
        Environment = [ "PI_CONFIG_DIR=/var/lib/omp-auth" ];
        ExecStart = "${omp}/bin/omp auth-broker serve --bind=127.0.0.1:8765";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    omp-auth-gateway = {
      description = "OMP auth gateway";
      after = [ "omp-auth-broker.service" ];
      requires = [ "omp-auth-broker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "maximousblk";
        Group = "users";
        StateDirectory = "omp-auth";
        WorkingDirectory = "/var/lib/omp-auth";
        Environment = [
          "PI_CONFIG_DIR=/var/lib/omp-auth"
          "OMP_AUTH_BROKER_URL=http://127.0.0.1:8765"
        ];
        ExecStart = "${omp}/bin/omp auth-gateway serve --bind=127.0.0.1:4000 --no-auth";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  optx.tailscale.services.omp = {
    serve."https:443" = "http://localhost:4000";
    backends = [ "omp-auth-gateway.service" ];
  };
}
