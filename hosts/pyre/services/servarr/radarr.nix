{
  config,
  lib,
  servarr,
  ...
}:
let
  port = 7878;
in
{
  age.secrets.servarr-radarr-api-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 16
    '';
  };
  nixflix.radarr = {
    enable = true;
    openFirewall = false;
    mediaDirs = [ "${servarr.media_dir}/library/movies" ];
    config.apiKey._secret = config.age.secrets.servarr-radarr-api-key.path;
    config.hostConfig = {
      inherit port;
      bindAddress = "127.0.0.1";
      authenticationMethod = "external";
      username = null;
      password = null;
    };
  };

  nixflix.recyclarr.config.radarr.radarr = {
    quality_profiles = [
      {
        trash_id = "0896c29d74de619df168d23b98104b22";
        reset_unmatched_scores.enabled = true;
        min_format_score = 180;
      }
      {
        trash_id = "722b624f9af1e492284c4bc842153a38";
        name = "[Anime] Remux-1080p";
        reset_unmatched_scores.enabled = true;
      }
      {
        trash_id = "722b624f9af1e492284c4bc842153a38";
        name = "[Anime] Remux-1080p - Dual Audio";
        min_format_score = 2000;
        reset_unmatched_scores.enabled = true;
      }
    ];
    custom_formats = [
      {
        trash_ids = [ "4a3b087eea2ce012fcc1ce319259a3be" ];
        assign_scores_to = [
          {
            name = "[Anime] Remux-1080p - Dual Audio";
            score = 2000;
          }
        ];
      }
    ];
  };

  # Set umask for group write permissions (0002 = rwxrwxr-x for dirs, rw-rw-r-- for files)
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";

  optx.tailscale.services.radarr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "radarr.service" ];
  };

  topology.self.services.radarr = {
    name = "Radarr";
    info = "Movie management";
    icon = "services.radarr";
  };
}
