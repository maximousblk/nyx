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
          async.enabled = true;
          async.pollWaitDuration = "10m";
          autolearn.enabled = true;
          bash.autoBackground.enabled = true;
          bashInterceptor.enabled = true;
          browser.enabled = false;
          commands.enableClaudeProject = false;
          commands.enableClaudeUser = false;
          commands.enableOpencodeProject = false;
          commands.enableOpencodeUser = false;
          compaction.handoffSaveToDisk = true;
          compaction.strategy = "shake";
          contextPromotion.enabled = false;
          dev.autoqa.consent = "denied";
          display.shimmer = "kitt";
          display.tabWidth = 2;
          edit.fuzzyThreshold = 0.98;
          edit.mode = "patch";
          github.enabled = true;
          hideThinkingBlock = true;
          images.autoResize = true;
          inspect_image.enabled = true;
          lsp.diagnosticsOnWrite = false;
          lsp.enabled = false;
          lsp.lazy = false;
          marketplace.autoUpdate = "off";
          mcp.enableProjectConfig = false;
          memory.backend = "mnemopi";
          mnemopi.scoping = "global";
          model.advisor.enabled = true;
          model.advisor.syncBacklog = 5;
          model.includeModelInPrompt = false;
          model.personality = "pragmatic";
          modelRoles.commit = "opencode-go/deepseek-v4-flash";
          modelRoles.default = "minimax-code/MiniMax-M3";
          modelRoles.plan = "minimax-code/MiniMax-M3";
          modelRoles.slow = "minimax-code/MiniMax-M3";
          modelRoles.smol = "opencode-go/deepseek-v4-flash";
          plan.defaultOnStartup = true;
          readLineNumbers = true;
          showHardwareCursor = true;
          skills.enableClaudeProject = false;
          skills.enableClaudeUser = false;
          skills.enableCodexUser = false;
          skills.enablePiProject = false;
          skills.enablePiUser = false;
          skills.includeSkills = [ ];
          startup.checkUpdate = false;
          startup.setupWizard = false;
          statusLine.preset = "nerd";
          statusLine.separator = "powerline-thin";
          task.eager = "default";
          task.enableLsp = false;
          task.maxConcurrency = 4;
          task.maxRecursionDepth = 0;
          task.showResolvedModelBadge = true;
          terminal.showImages = true;
          todo.eager = "always";
          tools.discoveryMode = "all";
          treeFilterMode = "no-tools";

          skills.customDirectories = [
            "~/.agent/skills"
            "${skillsDir}"
          ];
          enabledModels = [
            "openai-codex/gpt-5.5"
            "openai-codex/gpt-5.4-mini"

            "minimax-code/MiniMax-M3"

            "opencode-go/deepseek-v4-pro"
            "opencode-go/deepseek-v4-flash"
            "opencode-go/glm-5.1"
            "opencode-go/minimax-m3"

            "opencode-zen/big-pickle"
            "opencode-zen/nemotron-3-ultra-free"
          ];
        };
      }
    ];
  };
}
