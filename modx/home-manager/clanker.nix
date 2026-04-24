{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.optx.clanker;
in
{
  options.optx.clanker = {
    opencode.enable = lib.mkEnableOption "opencode with MCP integration";
    claude.enable = lib.mkEnableOption "claude-code with MCP integration";
    ollama = {
      enable = lib.mkEnableOption "Ollama local LLM service";
      acceleration = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            false
            "rocm"
            "cuda"
          ]
        );
        default = false;
        description = "Hardware acceleration for Ollama (false, \"rocm\", or \"cuda\").";
      };
    };
  };

  config = lib.mkMerge [

    (lib.mkIf (cfg.opencode.enable || cfg.claude.enable) {
      home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";

      home.packages = [ pkgs.crush ];

      programs.mcp = {
        enable = true;
        servers = {
          gh_grep.url = "https://mcp.grep.app";
          context7.url = "https://mcp.context7.com/mcp";
          linear.url = "https://mcp.linear.app/mcp";
          lightpanda = {
            command = lib.getExe pkgs.nur.repos.xddxdd.lightpanda;
            args = [ "mcp" ];
          };
        };
      };
    })

    (lib.mkIf cfg.opencode.enable {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;

        tui.theme = "system";

        settings = {
          autoupdate = false;
          share = "disabled";
          default_agent = "plan";
          snapshot = false;

          model = "openai/gpt-5.5";
          small_model = "openai/gpt-5.4-mini";

          lsp.rust.disabled = true;

          watcher.ignore = [
            "node_modules/**"
            "dist/**"
            ".git/**"
            "*.sqlite"
          ];

          permission = {
            "*" = "ask";
            read = "allow";
            glob = "allow";
            grep = "allow";
            list = "allow";
            lsp = "allow";
            webfetch = "allow";
            todoread = "allow";
            todowrite = "allow";
            task = "allow";
          };

          agent = {
            plan.permission = {
              edit = "ask";
              bash = "ask";
            };
            build.permission = {
              edit = "ask";
              bash = "ask";
            };
          };
        };
      };
    })

    (lib.mkIf (cfg.opencode.enable && cfg.ollama.enable) {
      programs.opencode.settings.provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";
        options.baseURL = "http://localhost:11434/v1";
        models."gemma4:26b".name = "Gemma 4";
      };
    })

    (lib.mkIf cfg.claude.enable {
      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;

        settings = {
          model = "sonnet";
          effortLevel = "low";
          permissions = {
            allow = [ ];
            defaultMode = "plan";
          };
        };
      };
    })

    (lib.mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        acceleration = cfg.ollama.acceleration;
      };
    })

  ];
}
