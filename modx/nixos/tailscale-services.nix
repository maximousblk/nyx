{ config, lib, ... }:

let
  cfg = config.optx.tailscale.services;

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

      # Remaining unitConfig options (non-list)
      remainingUnitConfig = removeAttrs svc.unitConfig [
        "After"
        "Wants"
        "Requires"
        "BindsTo"
        "PartOf"
      ];

      # Extract install options
      userWantedBy = svc.installConfig.WantedBy or [ ];
      userRequiredBy = svc.installConfig.RequiredBy or [ ];

      remainingInstallConfig = removeAttrs svc.installConfig [
        "WantedBy"
        "RequiredBy"
      ];
    in
    {
      name = "${name}-tailscale-svc";
      value = {
        description = "Tailscale Service: ${name}";

        # Merge with default After (always wait for tailscaled)
        after = [ "tailscaled.service" ] ++ userAfter;
        wants = userWants;
        requires = userRequires;
        bindsTo = userBindsTo;
        partOf = userPartOf;

        # Install section - don't start on boot by default, only via dependency chain
        wantedBy = userWantedBy;
        requiredBy = userRequiredBy;

        # Pass through remaining unit config
        unitConfig = remainingUnitConfig // remainingInstallConfig;

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.concatStringsSep " " [
            "${config.services.tailscale.package}/bin/tailscale"
            "serve"
            "--service=svc:${name}"
            (protocolFlag svc.protocol svc.port)
            svc.target
          ];
          ExecStop = "${config.services.tailscale.package}/bin/tailscale serve clear svc:${name}";
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
