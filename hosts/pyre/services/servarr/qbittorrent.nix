{
  config,
  pkgx,
  servarr,
  ...
}:
let
  port = 8282;
in
{
  age.secrets.servarr-qui-session-secret = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 32
    '';
  };
  age.secrets.servarr-qui-oidc-env.mode = "0400";
  systemd.services.qui.serviceConfig.EnvironmentFile = config.age.secrets.servarr-qui-oidc-env.path;

  services.qui = {
    enable = true;
    secretFile = config.age.secrets.servarr-qui-session-secret.path;
    settings = {
      host = "127.0.0.1";
      port = 7476;
      dataDir = "${servarr.state_dir}/qui";
      disableSelfUpdate = true;
      sessionCookieSecure = true;
      oidcEnabled = true;
      oidcIssuer = "https://idp.pony-clownfish.ts.net";
      oidcRedirectUrl = "https://qui.pony-clownfish.ts.net/api/auth/oidc/callback";
      oidcDisableBuiltInLogin = true;
    };
  };

  systemd.tmpfiles.settings."10-servarr"."${servarr.state_dir}/qui".d = {
    mode = "0750";
    user = "qui";
    group = "qui";
  };

  optx.tailscale.services.qui = {
    serve."https:443" = "http://localhost:7476";
    backends = [ "qui.service" ];
  };

  nixflix.torrentClients.qbittorrent = {
    enable = true;
    vpn.enable = false;
    profileDir = "${servarr.state_dir}/qbittorrent";
    downloadsDir = "${servarr.media_dir}/torrents";
    webuiPort = port;
    categories = {
      tv = "${servarr.media_dir}/torrents/tv";
      anime = "${servarr.media_dir}/torrents/anime";
      movie = "${servarr.media_dir}/torrents/movie";
    };
    serverConfig.Preferences.WebUI = {
      Address = "127.0.0.1";
      LocalHostAuth = false;
    };
  };

  nixflix.downloadarr.qbittorrent.categories = {
    sonarr = "tv";
    sonarr-anime = "anime";
    radarr = "movie";
  };

  optx.tailscale.services.qbittorrent = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "qbittorrent.service" ];
  };

  topology.self.services.qbittorrent = {
    name = "qBittorrent";
    info = "Torrent downloads";
    icon = pkgx.topology-icons.qbittorrent;
  };
}
