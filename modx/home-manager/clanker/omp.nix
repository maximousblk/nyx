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
  paseoSkills = "${inputs.paseo}/skills";
  herdrSkills = pkgs.runCommand "herdr-omp-skills" { } ''
    mkdir -p $out/herdr
    cp ${pkgs.herdr.src}/skills/herdr/SKILL.md $out/herdr/SKILL.md
  '';
in
{
  options.optx.clanker.omp = {
    enable = lib.mkEnableOption "omp coding agent";
    memory = {
      backend = lib.mkOption {
        type = lib.types.enum [
          "hindsight"
          "mnemopi"
        ];
        default = "mnemopi";
        description = "Memory backend for OMP.";
      };
      hindsightApiUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Hindsight API URL when using the Hindsight memory backend.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.memory.backend != "hindsight" || cfg.memory.hindsightApiUrl != null;
        message = "optx.clanker.omp.memory.hindsightApiUrl must be set for the Hindsight backend.";
      }
    ];

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];

    home.sessionVariables.PUPPETEER_EXECUTABLE_PATH = lib.getExe pkgs.brave-origin;

    home.file = lib.mkMerge [
      {
        ".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" (
          {
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
            compaction.strategy = "snapcompact";
            contextPromotion.enabled = false;
            dev.autoqa = false;
            dev.autoqaConsent = "denied";
            display.cacheMissMarker = true;
            display.shimmer = "kitt";
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
            memory.backend = cfg.memory.backend;
            advisor.enabled = false;
            advisor.syncBacklog = "5";
            personality = "pragmatic";
            modelRoles.advisor = "openai-codex/gpt-5.6-terra:low";
            modelRoles.commit = "openai-codex/gpt-5.6-luna:low";
            modelRoles.default = "openai-codex/gpt-5.6-terra:low";
            modelRoles.designer = "openai-codex/gpt-5.6-terra:low";
            modelRoles.plan = "openai-codex/gpt-5.6-terra:low";
            modelRoles.slow = "openai-codex/gpt-5.6-sol:low";
            modelRoles.smol = "openai-codex/gpt-5.6-luna:low";
            modelRoles.task = "openai-codex/gpt-5.6-terra:low";
            modelRoles.tiny = "openai-codex/gpt-5.6-luna:low";
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
            treeFilterMode = "no-tools";
            tui.hyperlinks = "always";
            tui.tight = true;
            worktree.base = "~/projects";

            skills.customDirectories = [
              "${skillsDir}"
              "${herdrSkills}"
              paseoSkills
            ];
            extensions = [ "${pkgs.herdr.src}/src/integration/assets/omp/herdr-agent-state.ts" ];
          }
          // lib.optionalAttrs (cfg.memory.backend == "mnemopi") { mnemopi.scoping = "global"; }
          // lib.optionalAttrs (cfg.memory.backend == "hindsight") {
            hindsight.apiUrl = cfg.memory.hindsightApiUrl;
            hindsight.apiToken = "";
            hindsight.bankId = "aftershoot";
            hindsight.scoping = "global";
            hindsight.autoRecall = true;
            hindsight.autoRetain = true;
            hindsight.retainEveryNTurns = 3;
            hindsight.retainMode = "last-turn";
            hindsight.recallBudget = "mid";
            hindsight.recallContextTurns = 3;
            hindsight.recallTypes = [
              "world"
              "experience"
              "observation"
            ];
            hindsight.mentalModelsEnabled = true;
            hindsight.mentalModelAutoSeed = true;
          }
        );
      }
    ];
  };
}
