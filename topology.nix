{ inputs, ... }:
{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem =
    { ... }:
    {
      topology.modules = [
        (
          { config, ... }:
          let
            inherit (config.lib.topology)
              mkInternet
              mkRouter
              mkSwitch
              mkDevice
              mkConnection
              ;
          in
          {
            networks.upstream = {
              name = "Upstream";
              cidrv4 = "192.168.0.0/24";
              style = {
                primaryColor = "#f9a8a8";
                secondaryColor = null;
                pattern = "solid";
              };
            };

            networks.nyx = {
              name = "NYX";
              cidrv4 = "192.168.69.0/24";
              style = {
                primaryColor = "#a7f3d0";
                secondaryColor = null;
                pattern = "solid";
              };
            };

            networks.tailscale = {
              name = "Tailscale";
              cidrv4 = "100.64.0.0/10";
              style = {
                primaryColor = "#a5d8ff";
                secondaryColor = null;
                pattern = "dotted";
              };
            };

            networks.containers = {
              name = "Container Network";
              cidrv4 = "10.69.0.0/16";
              style = {
                primaryColor = "#9ca3af";
                secondaryColor = "#d1d5db";
                pattern = "dashed";
              };
            };

            nodes.internet = mkInternet { connections = mkConnection "ont" "pon"; };

            nodes.ont = mkDevice "Airtel ONT-RG" {
              info = "ISP-provided optical network terminal/router";
              interfaceGroups = [
                [ "pon" ]
                [ "wifi" ]
              ];
              interfaces.pon.type = "fiber-duplex";
              interfaces.wifi = {
                type = "wifi";
                network = "upstream";
                physicalConnections = [
                  {
                    node = "extender";
                    interface = "wifi";
                  }
                ];
              };
            };

            nodes.extender = mkDevice "Range Extender" {
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
              };
              interfaces.eth.type = "ethernet";
              connections.eth = mkConnection "router" "wan";
            };

            nodes.router = mkRouter "Router" {
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
              interfaces.lan1.network = "nyx";
            };

            nodes.switch = mkSwitch "Switch" {
              info = "TP-Link TL-SG1008D";
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
                  node = "router";
                  interface = "lan1";
                  renderer.reverse = true;
                }
              ];

            };
          }
        )
      ];
    };
}
