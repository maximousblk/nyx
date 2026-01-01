{ config, common, ... }:
let
  persist = "${common.paths.data}/karakeep";
  data_meilisearch = "${persist}/meili";
  data_karakeep = "${persist}/data";

  net = config.virtualisation.quadlet.networks.karakeep;
  chrome = config.virtualisation.quadlet.containers.karakeep-chrome;
  meili = config.virtualisation.quadlet.containers.karakeep-meilisearch;

  nextauthSecretEnv = config.age.secrets.karakeep-env-nextauth-secret.path;
  meiliMasterKeyEnv = config.age.secrets.karakeep-env-meili-master-key.path;
in
{
  # NEXTAUTH_SECRET - used by karakeep only
  age.secrets.karakeep-env-nextauth-secret = {
    mode = "0400";
    generator.script =
      { pkgs, ... }:
      ''
        echo -n "NEXTAUTH_SECRET="
        ${pkgs.pwgen}/bin/pwgen -s 48 1
      '';
  };

  # MEILI_MASTER_KEY - used by both meilisearch and karakeep
  age.secrets.karakeep-env-meili-master-key = {
    mode = "0400";
    generator.script =
      { pkgs, ... }:
      ''
        echo -n "MEILI_MASTER_KEY="
        ${pkgs.pwgen}/bin/pwgen -s 48 1
      '';
  };

  topology.self.services.karakeep = {
    name = "Karakeep";
    info = "Bookmark manager";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/karakeep-light.svg";
      sha256 = "06mic8gs6ca36rkwh20sq3ykw5dlqj2nsz760j78pfg5g2krhrrg";
    };
  };

  systemd.tmpfiles.settings."10-karakeep" = {
    "${data_meilisearch}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
    "${data_karakeep}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
  };

  virtualisation.quadlet = {

    networks.karakeep = {
      networkConfig = {
        subnets = [ "10.69.1.0/24" ];
        driver = "bridge";
      };
    };

    containers = {

      # --- CHROME ---
      karakeep-chrome = {
        autoStart = true;
        containerConfig = {
          image = "gcr.io/zenika-hub/alpine-chrome:124";

          exec = [
            "--no-sandbox"
            "--disable-gpu"
            "--disable-dev-shm-usage"
            "--remote-debugging-address=0.0.0.0"
            "--remote-debugging-port=9222"
            "--hide-scrollbars"
          ];

          networks = [ net.ref ];
          networkAliases = [ "karakeep-chrome" ];
        };

        serviceConfig.Restart = "always";
      };

      # --- MEILISEARCH ---
      karakeep-meilisearch = {
        autoStart = true;
        containerConfig = {
          image = "getmeili/meilisearch:v1.13.3";

          networks = [ net.ref ];
          networkAliases = [ "karakeep-meilisearch" ];

          volumes = [ "${data_meilisearch}:/meili_data" ];

          environmentFiles = [ meiliMasterKeyEnv ];
          environments = common.env // {
            MEILI_NO_ANALYTICS = "true";
            MEILI_ADDR = "http://0.0.0.0:7700";
          };
        };

        serviceConfig.Restart = "always";
        unitConfig.RequiresMountsFor = data_meilisearch;
      };

      # --- KARAKEEP APP ---
      karakeep = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/karakeep-app/karakeep:release";
          publishPorts = [ "3000:3000" ];

          networks = [ net.ref ];
          networkAliases = [ "karakeep" ];
          volumes = [ "${data_karakeep}:/data" ];

          environmentFiles = [
            nextauthSecretEnv
            meiliMasterKeyEnv
          ];
          environments = common.env // {
            DATA_DIR = "/data";
            MEILI_ADDR = "http://karakeep-meilisearch:7700";
            BROWSER_WEB_URL = "http://karakeep-chrome:9222";
            NEXTAUTH_URL = "http://pyre.pony-clownfish.ts.net:3000";
          };
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [
            chrome.ref
            meili.ref
          ];
          Requires = [
            chrome.ref
            meili.ref
          ];
          RequiresMountsFor = data_karakeep;
        };
      };
    };
  };
}
