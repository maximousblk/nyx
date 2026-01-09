{
  config,
  common,
  modx,
  ...
}:
let
  persist = "${common.paths.data}/servarr";
  media_dir = "${persist}/media";
  state_dir = "${persist}/state";
in
{
  imports = [
    modx.nixos.tailscale-services
    ./transmission.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./bazarr.nix
    ./jellyfin.nix
    ./jellyseerr.nix
  ];

  _module.args.servarr = { inherit persist media_dir state_dir; };

  nixarr = {
    enable = true;
    mediaDir = media_dir;
    stateDir = state_dir;
  };

  systemd.tmpfiles.settings."10-servarr" = {
    "${persist}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${media_dir}".d = {
      mode = "0775";
      user = "root";
      group = "media";
    };
    "${state_dir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
  };

  virtualisation.quadlet.containers.flaresolverr = {
    autoStart = true;
    containerConfig = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      publishPorts = [ "127.0.0.1:8191:8191" ];
      environments = common.env // {
        LOG_LEVEL = "info";
      };
    };
    serviceConfig.Restart = "always";
  };
}
