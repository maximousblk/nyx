{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.optx.clanker.omp;
  yamlFormat = pkgs.formats.yaml { };
  skillsDir = ./skills;
in
{
  options.optx.clanker.omp = {
    enable = lib.mkEnableOption "omp coding agent";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.llm-agents.omp ];

    home.file = lib.mkMerge [
      {
        ".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" {
          browser.enabled = false;
          renderMermaid.enabled = true;
          bash.autoBackground.enabled = true;
          async.enabled = true;
          async.pollWaitDuration = "10m";
          hideThinkingBlock = true;
          lsp.enabled = false;
          task.enableLsp = false;
          marketplace.autoUpdate = "off";
          dev.autoqa.consent = "denied";
          skills.enableCodexUser = false;
          skills.enableClaudeUser = false;
          skills.enableClaudeProject = false;
          skills.enablePiUser = false;
          skills.enablePiProject = false;
          skills.includeSkills = [ ];
          skills.customDirectories = [
            "~/.agent/skills"
            "${skillsDir}"
          ];
          display.tabWidth = 2;
          todo.eager = true;
          task.eager = false;
          inspect_image.enabled = true;
          commands.enableClaudeUser = false;
          commands.enableClaudeProject = false;
          commands.enableOpencodeUser = false;
          commands.enableOpencodeProject = false;
          modelRoles.default = "opencode-go/deepseek-v4-pro";
          modelRoles.smol = "opencode-go/deepseek-v4-flash";
          modelRoles.plan = "opencode-go/deepseek-v4-pro";
          modelRoles.slow = "opencode-go/deepseek-v4-pro";
          modelRoles.commit = "opencode-go/deepseek-v4-flash";
          enableMCP = false;
          memory.backend = "mnemopi";
          mnemopi.scoping = "global";
          startup.checkUpdate = false;
          startup.setupWizard = false;
          enabledModels = [
            "openai-codex/gpt-5.5"
            "opencode-go/deepseek-v4-pro"
            "opencode-go/mimo-v2.5-pro"
            "openai-codex/gpt-5.4-mini"
            "opencode-go/deepseek-v4-flash"
            "opencode-zen/big-pickle"
            "opencode-zen/minimax-m3-free"
          ];
        };
      }
    ];
  };
}
