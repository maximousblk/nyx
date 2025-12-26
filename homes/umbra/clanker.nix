{ lib, pkgs, ... }:
{
  config = {
    programs.mcp = {
      enable = true;
      servers = {
        gh_grep.url = "https://mcp.grep.app";
        context7.url = "https://mcp.context7.com/mcp";
        playwright.command = lib.getExe pkgs.playwright-mcp;
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
          # Write operations - require approval
          bash = "ask";
          edit = "ask";
          skill = "ask";
          doom_loop = "ask";
          external_directory = "ask";

          # Read operations - always allow
          webfetch = "allow";
        };
      };
    };
  };
}
