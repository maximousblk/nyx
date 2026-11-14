{
  config,
  lib,
  modx,
  pkgs,
  pkgx,
  ...
}:
let
  origin = "https://cliproxyapi.pony-clownfish.ts.net";
  sharedEnv = config.age.secrets.cliproxyapi-env.path;
  proxyEnv = config.age.secrets.cliproxyapi-proxy-env.path;
in
{
  imports = [
    modx.nixos.tailscale-services
    modx.nixos.secrets
  ];

  age.secrets.cliproxyapi-env = {
    generator.script = { pkgs, ... }: ''
      management=$(${pkgs.openssl}/bin/openssl rand -hex 32)
      printf 'MANAGEMENT_PASSWORD=%s\n' "$management"
      printf 'OMCPA_CPA_MANAGEMENT_KEY=%s\n' "$management"
      printf 'OMCPA_MASTER_KEY=%s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 32)"
    '';
  };
  age.secrets.cliproxyapi-proxy-env = { };

  services.cliproxyapi = {
    enable = true;
    environmentFile = sharedEnv;
    settings = {
      config-version = 8;
      # Public compatibility token; Tailscale ACLs are the inference access boundary.
      access.api-keys = [ "aperture" ];
      server = {
        host = "127.0.0.1";
        port = 8317;
      };
      routing = {
        session-affinity = true;
        strategy = "fill-first";
      };
      observability = {
        logs = {
          logging-to-file = true;
          request-log = true;
        };
        usage.usage-statistics-enabled = true;
      };
      upstream.codex.upstream-request-compression = true;
      plugins = {
        enabled = false;
        store-sources = [ ];
        configs = { };
      };
      management = {
        allow-remote = false;
        disable-control-panel = true;
        disable-auto-update-panel = true;
      };
    };
  };

  users.users.oh-my-cpa = {
    isSystemUser = true;
    group = "oh-my-cpa";
  };
  users.groups.oh-my-cpa = { };
  systemd.services.oh-my-cpa = {
    description = "Oh My CPA management console";
    wantedBy = [ "multi-user.target" ];
    after = [ "cliproxyapi.service" ];
    environment = {
      OMCPA_LISTEN_ADDR = "127.0.0.1:8319";
      OMCPA_PUBLIC_URL = origin;
      OMCPA_DATA_DIR = "/var/lib/oh-my-cpa";
      OMCPA_CPA_BASE_URL = "http://127.0.0.1:8317";
      OMCPA_UPDATE_CHECK_ENABLED = "false";
      OMCPA_UPDATER_ENABLED = "false";
    };
    serviceConfig = {
      User = "oh-my-cpa";
      Group = "oh-my-cpa";
      StateDirectory = "oh-my-cpa";
      StateDirectoryMode = "0700";
      EnvironmentFile = sharedEnv;
      ExecStart = lib.getExe pkgx.oh-my-cpa;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/relvacode/caddy-oidc@v0.4.3" ];
      hash = "sha256-c7DZ6hTD2rjOKpZR+Lu2Nu91O5RZ3sTnedgQMaHJSOI=";
    };
    enableReload = false;
    globalConfig = ''
      admin off
      persist_config off
      auto_https off
      servers {
        trusted_proxies static 127.0.0.1/32 ::1/128
      }
      order oidc before reverse_proxy
      oidc {
        issuer {$OIDC_ISSUER}
        client_id {env.OIDC_CLIENT_ID}
        client_secret {env.OIDC_CLIENT_SECRET}
        scope openid email profile
        authenticate cookie {
          name _omc_oidc
          secret {env.OIDC_COOKIE_SECRET}
          redirect_url ${origin}/oauth2/callback
        }
      }
    '';
    virtualHosts."http://:8318" = {
      listenAddresses = [ "127.0.0.1" ];
      extraConfig = ''
        @cpa path /v1/* /v1beta/* /backend-api/* /anthropic/callback /codex/callback /google/callback /antigravity/callback
        handle @cpa {
          reverse_proxy 127.0.0.1:8317 {
            flush_interval -1
          }
        }
        handle {
          route {
            # Tailscale ACLs own authorization.
            oidc {
              allow {
                user *
              }
            }
            handle /api/auth/session {
              reverse_proxy 127.0.0.1:8319 {
                method GET
                rewrite /api/v1/resources
                @missing status 401
                handle_response @missing {
                  request_body {
                    set `{"password":"{env.OMCPA_CPA_MANAGEMENT_KEY}"}`
                  }
                  reverse_proxy 127.0.0.1:8319 {
                    method POST
                    rewrite /api/auth/login
                    header_up Host cliproxyapi.pony-clownfish.ts.net
                    header_up Origin ${origin}
                    header_up X-Forwarded-Proto https
                    header_up Content-Type application/json
                  }
                }
                @valid status 200
                handle_response @valid {
                  header Cache-Control no-store
                  respond `{"authenticated":true}` 200
                }
              }
            }
            handle /api/auth/logout {
              header +Set-Cookie "_omc_oidc=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Lax"
              reverse_proxy 127.0.0.1:8319
            }
            handle {
              reverse_proxy 127.0.0.1:8319 {
                flush_interval -1
              }
            }
          }
        }
      '';
    };
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    sharedEnv
    proxyEnv
  ];

  topology.self.services.cliproxyapi = {
    name = "CLIProxyAPI / Oh My CPA";
    info = "CPA inference and tsidp-authenticated OMC through Caddy";
    icon = pkgx.topology-icons.proxy;
  };
  optx.tailscale.services.cliproxyapi = {
    serve."https:443" = "http://localhost:8318";
    backends = [ "caddy.service" ];
  };
}
