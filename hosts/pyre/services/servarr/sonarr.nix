{
  config,
  lib,
  servarr,
  ...
}:
let
  port = 8989;
in
{
  age.secrets.servarr-sonarr-api-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 16
    '';
  };
  age.secrets.servarr-sonarr-anime-api-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 16
    '';
  };
  nixflix.sonarr = {
    enable = true;
    openFirewall = false;
    mediaDirs = [ "${servarr.media_dir}/library/shows" ];
    config.apiKey._secret = config.age.secrets.servarr-sonarr-api-key.path;
    config.hostConfig = {
      inherit port;
      bindAddress = "127.0.0.1";
      authenticationMethod = "external";
      username = null;
      password = null;
    };
  };

  # Set umask for group write permissions (0002 = rwxrwxr-x for dirs, rw-rw-r-- for files)
  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";

  optx.tailscale.services.sonarr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "sonarr.service" ];
  };

  topology.self.services.sonarr = {
    name = "Sonarr";
    info = "TV show management";
    icon = "services.sonarr";
  };
  nixflix.sonarr-anime = {
    enable = true;
    openFirewall = false;
    mediaDirs = [ "${servarr.media_dir}/library/anime" ];
    config.apiKey._secret = config.age.secrets.servarr-sonarr-anime-api-key.path;
    config.hostConfig = {
      port = 8990;
      bindAddress = "127.0.0.1";
      authenticationMethod = "external";
      username = null;
      password = null;
    };
  };

  nixflix.recyclarr.config.sonarr.sonarr_anime = {
    quality_profiles = [
      {
        trash_id = "20e0fc959f1f1704bed501f23bdae76f";
        name = "[Anime] Remux-1080p";
        reset_unmatched_scores.enabled = true;
      }
      {
        trash_id = "20e0fc959f1f1704bed501f23bdae76f";
        name = "[Anime] Remux-1080p - Dual Audio";
        min_format_score = 2000;
        reset_unmatched_scores.enabled = true;
      }
    ];
    custom_formats = [
      {
        trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ];
        assign_scores_to = [
          {
            name = "[Anime] Remux-1080p - Dual Audio";
            score = 2000;
          }
        ];
      }
    ];
  };

  optx.tailscale.services.sonarr-anime = {
    serve."https:443" = "http://localhost:8990";
    backends = [ "sonarr-anime.service" ];
  };

  topology.self.services.sonarr-anime = {
    name = "Sonarr Anime";
    info = "Anime management";
    icon = "services.sonarr";
  };
}
