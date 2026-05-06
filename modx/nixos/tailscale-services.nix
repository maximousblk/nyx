# Runs `tailscale serve` imperatively on each start instead of using `set-config` because
# set-config drops HTTPS and registers services as plain HTTP — tailscale/tailscale#18381.
# Revisit when fixed: switch to declarative set-config or upstream tailscale nixos module if fully supported.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optx.tailscale.services;
  tailscale = lib.getExe config.services.tailscale.package;
  flock = "${pkgs.util-linux}/bin/flock";
  lockFile = "/run/tailscale-serve.lock";

  validProtocols = [
    "https"
    "http"
    "tcp"
    "tls-terminated-tcp"
  ];

  parseFrontend =
    frontend:
    let
      match = builtins.match "(${lib.concatStringsSep "|" validProtocols}):([0-9]+)" frontend;
    in
    if match == null then
      null
    else
      {
        protocol = builtins.elemAt match 0;
        port = lib.toInt (builtins.elemAt match 1);
      };

  validateFrontend =
    svcName: frontend:
    let
      parsed = parseFrontend frontend;
    in
    {
      assertion = parsed != null && parsed.port >= 1 && parsed.port <= 65535;
      message = "optx.tailscale.services.${svcName}.serve: invalid key '${frontend}' — must be {${lib.concatStringsSep "," validProtocols}}:{1-65535}";
    };

  serviceOpts =
    { ... }:
    {
      options = {
        serve = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          description = "Endpoint map: frontend (protocol:port) → backend target";
          example = {
            "https:443" = "http://localhost:8096";
          };
        };

        backends = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Systemd units backing this service. Sidecar drains when any stops.";
          example = [ "jellyfin.service" ];
        };
      };
    };

  # "https:443" → "--https=443"
  serveFlag =
    frontend:
    let
      parts = lib.splitString ":" frontend;
    in
    "--${builtins.elemAt parts 0}=${builtins.elemAt parts 1}";

  # Build a locked `tailscale serve` command for one endpoint
  serveCmd =
    name: frontend: backend:
    "${flock} ${lockFile} ${tailscale} serve --service=svc:${name} ${serveFlag frontend} ${lib.escapeShellArg backend}";

  mkStartScript =
    name: svc:
    let
      cmds = lib.mapAttrsToList (serveCmd name) svc.serve;
    in
    pkgs.writeShellScript "tailscale-svc-${name}-start" ''
      set -e
      ${tailscale} wait --timeout=60s
      ${lib.concatStringsSep "\n" cmds}
    '';

  mkStopScript =
    name:
    pkgs.writeShellScript "tailscale-svc-${name}-stop" ''
      ${flock} ${lockFile} ${tailscale} serve drain svc:${name} || true
      ${flock} ${lockFile} ${tailscale} serve clear svc:${name} || true
    '';

  mkServiceUnit =
    name: svc:
    lib.nameValuePair "tailscale-svc-${name}" {
      description = "Tailscale Service: ${name}";

      bindsTo = svc.backends;
      requires = [ "tailscaled.service" ];
      after = svc.backends ++ [ "tailscaled.service" ];
      wantedBy = svc.backends ++ [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = mkStartScript name svc;
        ExecStop = mkStopScript name;
        ExecStopPost = mkStopScript name;
      };
    };
in
{
  options.optx.tailscale.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule serviceOpts);
    default = { };
    description = "Tailscale Services with lifecycle management";
  };

  config = lib.mkIf (cfg != { }) {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "optx.tailscale.services requires services.tailscale.enable = true";
      }
    ]
    ++ lib.concatLists (lib.mapAttrsToList (name: svc: map (validateFrontend name) (builtins.attrNames svc.serve)) cfg);

    systemd.services = lib.mapAttrs' mkServiceUnit cfg;
  };
}
