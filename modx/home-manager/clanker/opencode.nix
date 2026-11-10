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
        model = "openai/gpt-6.1-terra";
        agents = {
          plan.model = "openai/gpt-6.1-sol";
          general.model = "openai/gpt-6-luna";
          explore.model = "openai/gpt-6-luna";
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
