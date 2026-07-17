{
  lib,
  pkgs,
  config,
  inputs,
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

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];

    home.file = lib.mkMerge [
      {
        ".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" {
          async.enabled = true;
          async.pollWaitDuration = "10m";
          autolearn.enabled = true;
          bash.autoBackground.enabled = true;
          bashInterceptor.enabled = true;
          browser.cmux = false;
          browser.enabled = false;
          browser.headless = false;
          commands.enableClaudeProject = false;
          commands.enableClaudeUser = false;
          commands.enableOpencodeProject = false;
          commands.enableOpencodeUser = false;
          compaction.handoffSaveToDisk = true;
          compaction.strategy = "shake";
          contextPromotion.enabled = false;
          dev.autoqa.consent = "no";
          display.cacheMissMarker = true;
          display.shimmer = "kitt";
          display.tabWidth = 2;
          edit.fuzzyMatch = false;
          edit.fuzzyThreshold = 0.98;
          edit.mode = "patch";
          eval.jl = true;
          eval.js = true;
          eval.py = true;
          eval.rb = true;
          features.unexpectedStopDetection = true;
          grep.contextAfter = 5;
          grep.contextBefore = 5;
          github.enabled = true;
          hideThinkingBlock = true;
          images.autoResize = true;
          includeModelInPrompt = false;
          inspect_image.enabled = true;
          lsp.diagnosticsOnWrite = false;
          lsp.enabled = false;
          lsp.lazy = false;
          marketplace.autoUpdate = "off";
          mcp.enableProjectConfig = false;
          memory.backend = "mnemopi";
          mnemopi.scoping = "global";
          advisor.enabled = true;
          advisor.syncBacklog = "5";
          personality = "pragmatic";
          modelRoles.advisor = "openai-codex/gpt-5.6-sol:low";
          modelRoles.commit = "opencode-zen/deepseek-v4-flash-free";
          modelRoles.default = "openai-codex/gpt-5.6-luna:medium";
          modelRoles.designer = "openai-codex/gpt-5.5";
          modelRoles.plan = "openai-codex/gpt-5.5";
          modelRoles.slow = "minimax-code/MiniMax-M3";
          modelRoles.smol = "opencode-zen/deepseek-v4-flash-free";
          modelRoles.task = "minimax-code/MiniMax-M3";
          modelRoles.tiny = "opencode-zen/deepseek-v4-flash-free";
          modelRoles.vision = "minimax-code/MiniMax-M3";
          plan.defaultOnStartup = false;
          plan.enabled = false;
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
          symbolPreset = "nerd";
          statusLine.preset = "custom";
          statusLine.separator = "powerline-thin";
          statusLine.compactThinkingLevel = true;
          statusLine.leftSegments = [
            "pi"
            "model"
            "mode"
            "path"
            "git"
            "pr"
            "subagents"
          ];
          statusLine.rightSegments = [
            "session_name"
            "cost"
            "context_pct"
          ];
          task.eager = "default";
          task.enableLsp = false;
          task.maxConcurrency = 4;
          task.maxRecursionDepth = 0;
          task.showResolvedModelBadge = true;
          terminal.showProgress = true;
          terminal.showImages = true;
          todo.eager = "preferred";
          tools.discoveryMode = "all";
          treeFilterMode = "no-tools";
          tui.hyperlinks = "always";
          tui.tight = true;
          worktree.base = "~/projects";

          skills.customDirectories = [
            "~/.agent/skills"
            "${skillsDir}"
          ];
          enabledModels = [
            "openai-codex/gpt-5.5"
            "openai-codex/gpt-5.6-luna"
            "openai-codex/gpt-5.6-sol"
            "openai-codex/gpt-5.6-terra"

            "minimax-code/MiniMax-M3"

            "opencode-go/glm-5.2"

            "opencode-zen/big-pickle"
            "opencode-zen/deepseek-v4-flash-free"
            "opencode-zen/nemotron-3-ultra-free"
          ];
        };
      }
      {
        ".omp/agent/skills/herdr/SKILL.md".source = pkgs.herdr.src + "/SKILL.md";
      }
      {
        ".omp/agent/extensions/herdr-omp-agent-state.ts".source = pkgs.herdr.src + "/src/integration/assets/omp/herdr-agent-state.ts";
      }
    ];
  };
}
