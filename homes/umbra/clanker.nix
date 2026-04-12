{ lib, pkgs, ... }:
let
  shadcn-mcp = pkgs.writeShellApplication {
    name = "shadcn-mcp";
    runtimeInputs = [ pkgs.bun ];
    text = ''exec bun x shadcn@latest mcp "$@"'';
  };
in
{
  config = {

    home.packages = [
      pkgs.crush
      pkgs.claude-code
      pkgs.nur.repos.xddxdd.lightpanda
    ];

    programs.mcp = {
      enable = true;
      servers = {
        gh_grep.url = "https://mcp.grep.app";
        context7.url = "https://mcp.context7.com/mcp";
        lightpanda = {
          command = lib.getExe pkgs.nur.repos.xddxdd.lightpanda;
          args = [ "mcp" ];
        };
        playwright.command = lib.getExe pkgs.playwright-mcp;
        shadcn.command = lib.getExe shadcn-mcp;
      };
    };

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;

      settings = {
        theme = "rosepine";
        autoupdate = false;
        share = "disabled";

        model = "openai/gpt-5.4";
        small_model = "openai/gpt-5.1-codex-mini";
        default_agent = "plan";

        lsp.rust.disabled = true;

        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              "gemma4:26b".name = "Gemma 4";
            };
          };
        };

        permission = {
          # Default: require approval
          "*" = "ask";

          # Read operations - always allow
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
          # Plan agent: Read-only, write operations require approval
          plan = {
            permission = {
              edit = "ask";
              bash = "ask";
            };
          };

          # Build agent: All tools enabled with approval for writes
          build = {
            permission = {
              edit = "ask";
              bash = "ask";
            };
          };
        };
      };
    };
  };
}
