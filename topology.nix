{ inputs, ... }:
{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      topology.pkgs = pkgs.extend (
        final: prev:
        let
          topologyPkgs = (import "${inputs.nix-topology}/pkgs/default.nix") final prev;

          # Let nodes grow to fit ports + port labels instead of being pinned
          # to the SVG card's minimum size.
          elk-to-svg-grow = topologyPkgs.elk-to-svg.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              sed -i 's|"\[MINIMUM_SIZE\]"|"[MINIMUM_SIZE, PORTS, PORT_LABELS]"|' main.js
            '';
          });

          # Main diagram only: stack multi-label ports vertically.
          patched-elk-to-svg = elk-to-svg-grow.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              sed -i '
                s|const nodePortLabel = (node_d, port_d, label_d) => {|const nodePortLabel = (node_d, port_d, label_d, idx, total) => {|
                s|x="''${node_d.x + port_d.x + label_d.x}"|x="''${node_d.x + port_d.x + port_d.labels[0].x}"|
                s|y="''${node_d.y + port_d.y + label_d.y}"|y="''${node_d.y + port_d.y + label_d.y - (total - 1 - idx) * 14}"|
                s|.map((label_d) => nodePortLabel(node_d, port_d, label_d))|.map((label_d, i, arr) => nodePortLabel(node_d, port_d, label_d, i, arr.length))|
              ' main.js
            '';
          });
        in
        topologyPkgs
        // {
          # Shim pkgs.jetbrains-mono so the renderer (which references this
          # attr by name) embeds Ioskeley Mono glyphs instead.
          jetbrains-mono = final.runCommand "ioskeley-as-jetbrains-mono" { } ''
            mkdir -p $out/share/fonts/truetype
            cp ${final.ioskeley-mono.normal-NF}/share/fonts/truetype/IoskeleyMonoNerdFont-Regular.ttf \
               $out/share/fonts/truetype/JetBrainsMono-Regular.ttf
            cp ${final.ioskeley-mono.normal-NF}/share/fonts/truetype/IoskeleyMonoNerdFont-Bold.ttf \
               $out/share/fonts/truetype/JetBrainsMono-Bold.ttf
          '';

          elk-to-svg = final.writeShellApplication {
            name = "elk-to-svg";
            runtimeInputs = [
              final.coreutils
              final.jq
            ];
            text = ''
              input=$1
              shift
              patched=$(mktemp)
              trap 'rm -f "$patched"' EXIT

              spacing='
                .layoutOptions["org.eclipse.elk.spacing.nodeNode"] = 60
                | .layoutOptions["org.eclipse.elk.spacing.labelLabel"] = 8
                | .layoutOptions["org.eclipse.elk.spacing.labelPort"] = 6
                | .layoutOptions["org.eclipse.elk.spacing.portsSurrounding"] = 28
                | .layoutOptions["org.eclipse.elk.spacing.portPort"] = 12
              '

              if [[ "$input" == *main.elk.json ]]; then
                jq "$spacing | .layoutOptions[\"org.eclipse.elk.direction\"] = \"DOWN\"" "$input" > "$patched"
                exec ${patched-elk-to-svg}/bin/elk-to-svg "$patched" "$@"
              else
                jq "$spacing" "$input" > "$patched"
                exec ${elk-to-svg-grow}/bin/elk-to-svg "$patched" "$@"
              fi
            '';
          };
        }
      );

      topology.modules = [
        (
          { config, lib, ... }:
          let
            inherit (config.lib.topology)
              mkInternet
              mkRouter
              mkSwitch
              mkDevice
              mkConnection
              mkConnectionRev
              ;
          in
          {
            renderers.elk.overviews.services.enable = false;
            renderers.elk.overviews.networks.enable = false;

            networks.internet.name = "Internet";
            networks.internet.cidrv4 = "0.0.0.0/0";
            networks.internet.style = {
              primaryColor = "#94a3b8";
              secondaryColor = null;
              pattern = "dotted";
            };

            networks.upstream.name = "Upstream";
            networks.upstream.cidrv4 = "192.168.0.0/24";
            networks.upstream.style = {
              primaryColor = "#f9a8a8";
              secondaryColor = null;
              pattern = "solid";
            };

            networks.nyx.name = "NYX";
            networks.nyx.cidrv4 = "192.168.69.0/24";
            networks.nyx.style = {
              primaryColor = "#a7f3d0";
              secondaryColor = null;
              pattern = "solid";
            };

            networks.tailscale.name = "Tailscale";
            networks.tailscale.cidrv4 = "100.64.0.0/10";
            networks.tailscale.style = {
              primaryColor = "#a5d8ff";
              secondaryColor = null;
              pattern = "dotted";
            };

            networks.wsl.name = "WSL";
            networks.wsl.cidrv4 = "172.30.0.0/16";
            networks.wsl.style = {
              primaryColor = "#c4b5fd";
              secondaryColor = null;
              pattern = "dotted";
            };

            networks.oracle.name = "OCI Internal";
            networks.oracle.cidrv4 = "169.254.0.0/16";
            networks.oracle.style = {
              primaryColor = "#fb923c";
              secondaryColor = null;
              pattern = "dashed";
            };

            networks.celest.name = "Celest Subnet";
            networks.celest.cidrv4 = "10.42.0.0/24";
            networks.celest.cidrv6 = "2603:c021:4009:7f00::/64";
            networks.celest.style = {
              primaryColor = "#fdba74";
              secondaryColor = null;
              pattern = "solid";
            };

            nodes.internet = lib.recursiveUpdate (mkInternet { connections = mkConnection "ont" "pon"; }) { interfaces."*".network = "internet"; };

            nodes.ont = mkDevice "Airtel ONT-RG" {
              info = "ISP-provided optical network terminal/router";
              interfaceGroups = [
                [ "pon" ]
                [ "wifi" ]
              ];
              interfaces.pon = {
                type = "fiber-duplex";
                network = "internet";
              };
              interfaces.wifi = {
                type = "wifi";
                network = "upstream";
              };
            };

            nodes.re200 = mkDevice "Range Extender" {
              info = "TP-Link RE200 AC750";
              interfaceGroups = [
                [
                  "wifi"
                  "eth"
                ]
              ];
              interfaces.wifi = {
                type = "wifi";
                network = "upstream";
                physicalConnections = [
                  {
                    node = "ont";
                    interface = "wifi";
                    renderer.reverse = true;
                  }
                ];
              };
              interfaces.eth = {
                type = "ethernet";
                network = "upstream";
              };
              connections.eth = mkConnection "hex" "ether1";
            };

            nodes.re305 = mkDevice "Range Extender" {
              info = "TP-Link RE305 AC1200";
              interfaceGroups = [
                [
                  "wifi"
                  "eth"
                ]
              ];
              interfaces.wifi = {
                type = "wifi";
                network = "upstream";
                physicalConnections = [
                  {
                    node = "ont";
                    interface = "wifi";
                    renderer.reverse = true;
                  }
                ];
              };
              interfaces.eth = {
                type = "ethernet";
                network = "upstream";
              };
              connections.eth = mkConnection "hex" "ether2";
            };

            nodes.hex = mkRouter "Router" {
              info = "MikroTik hEX RB750Gr3";
              interfaceGroups = [
                [
                  "ether1"
                  "ether2"
                ]
                [
                  "ether3"
                  "ether4"
                  "ether5"
                ]
              ];
              interfaces.ether1.network = "upstream";
              interfaces.ether2.network = "upstream";
              interfaces.ether3.network = "nyx";
              interfaces.ether4.network = "nyx";
              interfaces.ether5.network = "nyx";
            };

            nodes.ap = mkRouter "Wi-Fi AP" {
              info = "TP-Link Archer C6 AC1200";
              interfaceGroups = [
                [ "wan" ]
                [
                  "lan1"
                  "lan2"
                  "lan3"
                  "lan4"
                  "wifi"
                ]
              ];
              interfaces.wan = {
                network = "nyx";
                physicalConnections = [
                  {
                    node = "hex";
                    interface = "ether3";
                    renderer.reverse = true;
                  }
                ];
              };
              interfaces.wifi = {
                type = "wifi";
                network = "nyx";
              };
            };

            nodes.sg1005d = mkSwitch "TL-SG1005D" {
              info = "TP-Link TL-SG1005D 5-port switch";
              interfaceGroups = [
                [
                  "lan1"
                  "lan2"
                  "lan3"
                  "lan4"
                  "lan5"
                ]
              ];
              interfaces.lan1.physicalConnections = [
                {
                  node = "hex";
                  interface = "ether4";
                  renderer.reverse = true;
                }
              ];
            };

            nodes.sg1008d = mkSwitch "TL-SG1008D" {
              info = "TP-Link TL-SG1008D 8-port switch";
              interfaceGroups = [
                [
                  "lan1"
                  "lan2"
                  "lan3"
                  "lan4"
                  "lan5"
                  "lan6"
                  "lan7"
                  "lan8"
                ]
              ];
              interfaces.lan1.physicalConnections = [
                {
                  node = "hex";
                  interface = "ether5";
                  renderer.reverse = true;
                }
              ];
            };

            nodes.igw = mkRouter "Internet Gateway" {
              info = "OCI Internet Gateway (ap-mumbai-1)";
              interfaceGroups = [
                [ "wan" ]
                [ "lan" ]
              ];
              connections.wan = mkConnectionRev "internet" "*";
              interfaces.wan.network = "internet";
              interfaces.lan = {
                network = "oracle";
                virtual = true;
              };
              connections.lan = mkConnection "celest" "uplink";
            };

            nodes.celest = mkRouter "Celest VCN" {
              info = "OCI VCN + Subnet + NSG";
              interfaceGroups = [
                [ "uplink" ]
                [ "lan1" ]
              ];
              interfaces.uplink = {
                network = "oracle";
                virtual = true;
              };
              interfaces.lan1 = {
                network = "celest";
                virtual = true;
              };
              connections.lan1 = mkConnection "scry" "enp0s6";
            };
          }
        )
      ];
    };
}
