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
  herdrSkills = pkgs.runCommand "herdr-omp-skills" { } ''
    mkdir -p $out/herdr
    cp ${pkgs.herdr.src}/SKILL.md $out/herdr/SKILL.md
  '';
in
{
  options.optx.clanker.omp = {
    enable = lib.mkEnableOption "omp coding agent";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];

    home.sessionVariables.PUPPETEER_EXECUTABLE_PATH = lib.getExe pkgs.brave-origin;

    home.file = lib.mkMerge [
      {
        ".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" {
          async.enabled = true;
          async.pollWaitDuration = "10m";
          autolearn.enabled = true;
          bash.autoBackground.enabled = true;
          bashInterceptor.enabled = true;
          browser.cmux = false;
          browser.enabled = true;
          browser.headless = true;
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
          inspect_image.mode = "auto";
          lsp.diagnosticsOnWrite = false;
          lsp.enabled = false;
          lsp.lazy = false;
          marketplace.autoUpdate = "off";
          mcp.enableProjectConfig = false;
          tools.xdev = true;
          tools.xdevDocs = "catalog";
          memory.backend = "mnemopi";
          mnemopi.scoping = "global";
          advisor.enabled = false;
          advisor.syncBacklog = "5";
          personality = "pragmatic";
          modelRoles.advisor = "openai-codex/gpt-5.6-terra:low";
          modelRoles.commit = "openai-codex/gpt-5.6-luna:low";
          modelRoles.default = "openai-codex/gpt-5.6-luna:low";
          modelRoles.designer = "openai-codex/gpt-5.6-terra:low";
          modelRoles.plan = "openai-codex/gpt-5.6-terra:low";
          modelRoles.slow = "openai-codex/gpt-5.6-terra:low";
          modelRoles.smol = "opencode-zen/laguna-s-2.1-free";
          modelRoles.task = "openai-codex/gpt-5.6-luna:low";
          modelRoles.tiny = "opencode-zen/laguna-s-2.1-free";
          modelRoles.vision = "openai-codex/gpt-5.6-luna:low";
          plan.defaultOnStartup = false;
          plan.enabled = false;
          readLineNumbers = true;
          showHardwareCursor = true;
          skills.enableClaudeProject = false;
          skills.enableClaudeUser = false;
          skills.enableCodexUser = false;
          skills.enableAgentsProject = false;
          skills.enableAgentsUser = false;
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
          task.maxRecursionDepth = 1;
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
            "${skillsDir}"
            "${herdrSkills}"
          ];
          extensions = [ "${pkgs.herdr.src}/src/integration/assets/omp/herdr-agent-state.ts" ];
          enabledModels = [
            "openai-codex/gpt-5.6-luna"
            "openai-codex/gpt-5.6-terra"

            "opencode-zen/big-pickle"
            "opencode-zen/laguna-s-2.1-free"
          ];
        };
      }
    ];
  };
}
