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
    ];

    home.sessionVariables.OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";

    programs.mcp = {
      enable = true;
      servers = {
        gh_grep.url = "https://mcp.grep.app";
        context7.url = "https://mcp.context7.com/mcp";
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

        enabled_providers = [ "github-copilot" ];
        model = "claude-opus-4.5";
        small_model = "claude-haiku-4.5";
        default_agent = "plan";

        lsp.nixd = {
          command = [ (lib.getExe pkgs.nixd) ];
          extensions = [ ".nix" ];
        };

        formatter.nixfmt = {
          command = [
            (lib.getExe pkgs.nixfmt-rfc-style)
            "$FILE"
          ];
          extensions = [ ".nix" ];
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
