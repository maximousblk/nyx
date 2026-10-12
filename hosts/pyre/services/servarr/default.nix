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
    ./qbittorrent.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./jellyfin.nix
    ./seerr.nix
    ./dashbrr.nix
    ./cleanuparr.nix
  ];

  _module.args.servarr = { inherit persist media_dir state_dir; };

  nixflix = {
    enable = true;
    mediaDir = "${media_dir}/library";
    downloadsDir = "${media_dir}/torrents";
    stateDir = state_dir;
    postgres.enable = false;
    vpn.enable = false;
    theme.enable = false;
    nginx.enable = false;
    caddy.enable = false;
    recyclarr.enable = true;
  };

  systemd.tmpfiles.settings."10-servarr" = {
    "${persist}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${media_dir}".d = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "${state_dir}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
  };

}
