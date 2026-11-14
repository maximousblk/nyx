{
  lib,
  pkgs,
  config,
  inputs,
  pkgx,
  ...
}:
let
  cfg = config.optx.clanker.opencode;
  useAperture = config.optx.clanker.omp.defaultPreset == "aperture";
  modelProvider = if useAperture then "aperture" else "openai";
  herdrAssets = "${pkgs.herdr.src}/src/integration/assets/opencode";
in
{
  options.optx.clanker.opencode.enable = lib.mkEnableOption "opencode 2";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgx.omp-claude-connectors-bridge.cli
      pkgx.split-commit.package
    ];

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
      mutableSettings = true;
      cli = {
        theme.name = "system";
        session = {
          thinking = "hide";
          image_preview = true;
        };
        plugins = [ "${config.xdg.configHome}/opencode/herdr-opencode" ];
      };
      settings = {
        update = "disable";
        snapshots = false;
        default_agent = "plan";
        model = "${modelProvider}/gpt-6.1-terra";
        agents = {
          plan.model = "${modelProvider}/gpt-6.1-sol";
          general.model = "${modelProvider}/gpt-6-luna";
          explore.model = "${modelProvider}/gpt-6-luna";
        };
        providers = lib.optionalAttrs useAperture {
          aperture = {
            name = "Aperture";
            package = "@opencode/ai/providers/openai-compatible/responses";
            settings = {
              baseURL = "https://aperture.pony-clownfish.ts.net/v1";
              apiKey = "tailnet";
            };
            # OpenCode 2 has no generic /v1/models discovery; declare the supported routes.
            models = lib.genAttrs [ "gpt-5.6-luna" "gpt-5.6-terra" "gpt-6-luna" "gpt-6.1-sol" "gpt-6.1-terra" ] (model: {
              modelID = "openai-codex/${model}";
              limit = {
                context = 1050000;
                output = 128000;
              };
              capabilities = {
                tools = true;
                input = [
                  "text"
                  "image"
                ];
                output = [ "text" ];
                reasoning = {
                  supported = true;
                  effort = [
                    "low"
                    "medium"
                    "high"
                  ];
                };
              };
              settings.reasoningEffort = "medium";
            });
          };
        };
        watcher.ignore = [
          "node_modules/**"
          "dist/**"
          ".git/**"
          "*.sqlite"
        ];
        media.image.auto_resize = true;
        worktree.directory = "~/projects";
        experimental = {
          todo = true;
          subagent_depth = 1;
        };
        skills = [
          pkgx.split-commit.skills
          pkgx.omp-claude-connectors-bridge.skills
        ];
        permissions = [
          {
            action = "*";
            resource = "*";
            effect = "ask";
          }
          {
            action = "read";
            resource = "*";
            effect = "allow";
          }
          {
            action = "glob";
            resource = "*";
            effect = "allow";
          }
          {
            action = "grep";
            resource = "*";
            effect = "allow";
          }
          {
            action = "webfetch";
            resource = "*";
            effect = "allow";
          }
          {
            action = "subagent";
            resource = "*";
            effect = "allow";
          }
          {
            action = "read";
            resource = "*.env";
            effect = "ask";
          }
          {
            action = "read";
            resource = "*.env.*";
            effect = "ask";
          }
          {
            action = "read";
            resource = "*.env.example";
            effect = "allow";
          }
        ];
      };
    };

    # Store symlinks reject rewrites by the Herdr integration installer.
    xdg.configFile = {
      "opencode/plugins/herdr-agent-state.js" = {
        source = "${herdrAssets}/herdr-agent-state.js";
        force = true;
      };
      "opencode/herdr-tui-session.js" = {
        source = "${herdrAssets}/herdr-tui-session.js";
        force = true;
      };
      "opencode/herdr-opencode/tui.js" = {
        source = "${herdrAssets}/tui.js";
        force = true;
      };
    };
  };
}
