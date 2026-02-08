{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.optx.tailscale.services;
  tailscale = "${config.services.tailscale.package}/bin/tailscale";
  flock = "${pkgs.util-linux}/bin/flock";

  serviceOpts =
    { ... }:
    {
      options = {
        target = lib.mkOption {
          type = lib.types.str;
          example = "http://10.69.1.10:3000";
          description = "Target URL to proxy to (container IP or localhost)";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 443;
          description = "Port to expose on the Tailscale Service VIP";
        };

        protocol = lib.mkOption {
          type = lib.types.enum [
            "https"
            "http"
            "tcp"
            "tls-terminated-tcp"
          ];
          default = "https";
          description = "Protocol for the exposed endpoint";
        };

        unitConfig = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Systemd [Unit] section config passed through transparently";
        };

        serviceConfig = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Systemd [Service] section config passed through transparently";
        };

        installConfig = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Systemd [Install] section config passed through transparently";
        };
      };
    };

  protocolFlag =
    protocol: port:
    {
      "https" = "--https=${toString port}";
      "http" = "--http=${toString port}";
      "tcp" = "--tcp=${toString port}";
      "tls-terminated-tcp" = "--tls-terminated-tcp=${toString port}";
    }
    .${protocol};

  mkService =
    name: svc:
    let
      # Extract list-type unit options for proper merging
      userAfter = svc.unitConfig.After or [ ];
      userWants = svc.unitConfig.Wants or [ ];
      userRequires = svc.unitConfig.Requires or [ ];
      userBindsTo = svc.unitConfig.BindsTo or [ ];
      userPartOf = svc.unitConfig.PartOf or [ ];

      remainingUnitConfig = removeAttrs svc.unitConfig [
        "After"
        "Wants"
        "Requires"
        "BindsTo"
        "PartOf"
      ];

      userWantedBy = svc.installConfig.WantedBy or [ ];
      userRequiredBy = svc.installConfig.RequiredBy or [ ];

      remainingInstallConfig = removeAttrs svc.installConfig [
        "WantedBy"
        "RequiredBy"
      ];

      startScript = pkgs.writeShellScript "${name}-tailscale-serve" ''
        #!/bin/sh
        set -e # Exit immediately if a command exits with a non-zero status.

        # Wait for the tailscaled daemon to be ready.
        # The 'tailscale status' command will fail until the daemon is up and connected.
        until ${tailscale} status >/dev/null 2>&1; do
          echo "Waiting for tailscaled daemon to be ready for service '${name}'..."
          sleep 5
        done
        echo "tailscaled is ready."

        # Use flock to ensure only one 'tailscale serve' command runs at a time,
        # preventing race conditions when modifying the daemon's configuration.
        echo "Attempting to configure tailscale serve for '${name}'..."
        ${flock} /run/tailscale-serve.lock \
          ${tailscale} serve \
          --service=svc:${name} \
          ${protocolFlag svc.protocol svc.port} \
          ${svc.target}
        echo "tailscale serve for '${name}' configured successfully."
      '';

      stopScript = pkgs.writeShellScript "${name}-tailscale-clear" ''
        ${flock} /run/tailscale-serve.lock \
          ${tailscale} serve clear svc:${name}
      '';
    in
    {
      name = "${name}-tailscale-svc";
      value = {
        description = "Tailscale Service: ${name}";

        after = [ "tailscaled.service" ] ++ userAfter;
        wants = userWants;
        requires = [ "tailscaled.service" ] ++ userRequires;
        bindsTo = userBindsTo;
        partOf = userPartOf;

        wantedBy = userWantedBy;
        requiredBy = userRequiredBy;

        unitConfig = remainingUnitConfig // remainingInstallConfig;

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "5s";
          ExecStart = startScript;
          ExecStop = stopScript;
        }
        // svc.serviceConfig;
      };
    };
in
{
  options.optx.tailscale.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule serviceOpts);
    default = { };
    description = "Tailscale Services to expose via tailscale serve";
  };

  config = lib.mkIf (cfg != { }) {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "optx.tailscale.services requires services.tailscale.enable = true";
      }
    ];

    systemd.services = lib.mapAttrs' mkService cfg;
  };
}
