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
                pattern = "dashed";
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
            };

            nodes.internet = mkInternet { connections = mkConnection "extender" "wifi"; };

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
              connections.lan1 = mkConnection "switch" "lan1";
              connections.wifi = mkConnection "victus" "wlp0s20f3";
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
              connections.lan2 = mkConnection "pyre" "enp2s0";
              connections.lan3 = mkConnection "wisp" "eth0";
            };

            nodes.wisp = mkDevice "wisp" {
              info = "Raspberry Pi 4B 8GB";
              interfaceGroups = [
                [ "eth0" ]
                [ "tailscale0" ]
              ];
              interfaces.eth0 = {
                network = "nyx";
                addresses = [ "192.168.69.202" ];
              };
              interfaces.tailscale0 = {
                network = "tailscale";
                type = "tun";
                virtual = true;
                addresses = [ "100.100.2.1" ];
              };
            };
          }
        )
      ];
    };
}
