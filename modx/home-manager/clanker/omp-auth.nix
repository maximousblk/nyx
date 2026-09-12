{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  cfg = config.optx.clanker.omp-auth;
  omp = lib.getExe inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
in
{
  options.optx.clanker.omp-auth = {
    enable = lib.mkEnableOption "local OMP auth broker and gateway";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.omp-auth-broker = {
      Unit = {
        Description = "OMP auth broker";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = "${omp} auth-broker serve --bind=127.0.0.1:8765";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.omp-auth-gateway = {
      Unit = {
        Description = "OMP auth gateway";
        After = [ "omp-auth-broker.service" ];
        Requires = [ "omp-auth-broker.service" ];
      };
      Service = {
        Environment = [ "OMP_AUTH_BROKER_URL=http://127.0.0.1:8765" ];
        ExecStart = "${omp} auth-gateway serve --bind=127.0.0.1:4000 --no-auth";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
