{ ... }:
{
  config = {
    programs.opencode = {
      enable = true;
      settings = {
        theme = "rosepine";
        autoupdate = false;
        share = "disabled";

        enabled_providers = [ "github-copilot" ];
        model = "claude-opus-4.5";
        small_model = "claude-haiku-4.5";
        default_agent = "plan";

        mcp = {
          gh_grep = {
            type = "remote";
            url = "https://mcp.grep.app";
          };
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
