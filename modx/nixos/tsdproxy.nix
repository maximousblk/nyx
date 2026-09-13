{
  config,
  lib,
  pkgs,
  pkgx,
  ...
}:
let
  cfg = config.optx.tailscale.tsdproxy;
  yaml = pkgs.formats.yaml { };
  enabledNodes = lib.filterAttrs (_: node: node.enable) cfg.nodes;
  backends = lib.flatten (lib.mapAttrsToList (_: node: node.backends) enabledNodes);
  nodesFile = yaml.generate "tsdproxy-nodes.yaml" (
    lib.mapAttrs (
      _: node:
      removeAttrs node [
        "enable"
        "backends"
      ]
    ) enabledNodes
  );
  configFile = yaml.generate "tsdproxy.yaml" (
    lib.recursiveUpdate cfg.settings {
      docker.default = cfg.docker;
      tailscale = cfg.tailscale // {
        dataDir = "/var/lib/tsdproxy";
      };
    }
    // lib.optionalAttrs (enabledNodes != { }) {
      lists.nixos = cfg.list // {
        filename = nodesFile;
      };
    }
  );
in
{
  options.optx.tailscale.tsdproxy = {
    package = lib.mkPackageOption pkgx "tsdproxy" { };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional TSDProxy server configuration. Secret values must use TSDProxy's *File settings.";
    };

    tailscale = lib.mkOption {
      type = lib.types.attrs;
      default = {
        providers.default = { };
      };
      description = "TSDProxy Tailscale provider configuration. Use authKeyFile or clientSecretFile for credentials.";
    };

    docker = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration for the default Docker target provider.";
    };

    nodes = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          freeformType = yaml.type;
          options.enable = lib.mkEnableOption "this TSDProxy node" // {
            default = true;
          };
          options.backends = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Systemd units backing this TSDProxy node. TSDProxy stops when any enabled node backend stops.";
            example = [ "crafty.service" ];
          };
        }
      );
      default = { };
      description = "Static proxy nodes written to TSDProxy's generated list target provider. TSDProxy runs when at least one node is enabled.";
    };

    list = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration for the generated static-node list target provider.";
    };

  };

  config = lib.mkIf (enabledNodes != { }) {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "optx.tailscale.tsdproxy requires virtualisation.docker.enable = true";
      }
    ];

    users.groups.tsdproxy = { };
    users.users.tsdproxy = {
      isSystemUser = true;
      group = "tsdproxy";
      extraGroups = [ "docker" ];
    };

    systemd.services.tsdproxy = {
      description = "TSDProxy v3";
      bindsTo = backends;
      wants = [ "network-online.target" ];
      after = backends ++ [
        "network-online.target"
        "docker.service"
      ];
      requires = backends ++ [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "tsdproxy";
        Group = "tsdproxy";
        StateDirectory = "tsdproxy";
        ExecStart = "${lib.getExe cfg.package} --config ${configFile}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
