{
  lib,
  pkgs,
  config,
  inputs,
  pkgx,
  ...
}:
let
  cfg = config.optx.clanker.omp;
  jsonFormat = pkgs.formats.json { };
  yamlFormat = pkgs.formats.yaml { };
  ghidraPython = pkgs.python3.withPackages (ps: [ ps.pyghidra ]);
  # The paseo source root is not a loadable package, so expose only its skills directory.
  paseoSkills = pkgs.linkFarm "paseo-omp-skills" { skills = "${inputs.paseo}/skills"; };
  ompPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
  # Herdr panes set HERDR_ENV=1; Paseo sets PASEO_AGENT_ID on every agent it launches.
  omp = pkgs.symlinkJoin {
    inherit (ompPackage) name meta;
    paths = [ ompPackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/omp \
        --set PUPPETEER_EXECUTABLE_PATH ${pkgs.brave-origin}/bin/brave-origin \
        --set PI_BROWSER_WEBKIT 0 \
        --set JAVA_HOME ${pkgs.openjdk25} \
        --set PI_FORCE_IMAGE_PROTOCOL kitty \
        --run 'if [ "''${HERDR_ENV:-}" = 1 ]; then set -- -e ${pkgs.herdr.src} "$@"; fi' \
        --run 'if [ "''${HERDR_ENV:-}" = 1 ]; then set -- -e ${pkgs.herdr.src}/src/integration/assets/omp/herdr-agent-state.ts "$@"; fi' \
        --run 'if [ -n "''${PASEO_AGENT_ID:-}" ]; then set -- -e ${paseoSkills} "$@"; fi'
    '';
  };
  modelPresets = {
    aperture = {
      modelRoles = {
        smol = "aperture/openai-codex/gpt-6-luna:medium";
        default = "aperture/openai-codex/gpt-6.1-terra:medium";
        slow = "aperture/openai-codex/gpt-6.2-sol:medium";
        frontier = "aperture/openai-codex/gpt-6.2-astra:medium";

        advisor = "@slow";
        commit = "@smol";
        judge = "@smol";
        memory = "@tiny";
        plan = "@slow";
        task = "@smol";
        tiny = "@smol";
        vision = "@smol";
        widget = "@smol";
      };
      defaultThinkingLevel = "medium";
    };
    codex = {
      modelRoles = {
        smol = "openai-codex/gpt-6-luna:medium";
        default = "openai-codex/gpt-6.1-terra:medium";
        slow = "openai-codex/gpt-6.2-sol:medium";
        frontier = "openai-codex/gpt-6.2-astra:medium";

        advisor = "@slow";
        commit = "@smol";
        judge = "@smol";
        memory = "@tiny";
        plan = "@slow";
        task = "@smol";
        tiny = "@smol";
        vision = "@smol";
        widget = "@smol";
      };
      defaultThinkingLevel = "medium";
    };
    claude = {
      modelRoles = {
        smol = "anthropic/claude-haiku-5-5:medium";
        default = "anthropic/claude-haiku-5-5:medium";
        slow = "anthropic/claude-sonnet-5-5:medium";
        frontier = "anthropic/claude-opus-5-5:medium";

        advisor = "@slow";
        commit = "@smol";
        judge = "@smol";
        memory = "@tiny";
        plan = "@slow";
        task = "@smol";
        tiny = "@smol";
        vision = "@smol";
        widget = "@smol";
      };
      defaultThinkingLevel = "medium";
    };
  };
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
      mnemopi = lib.mkOption {
        type = lib.types.attrsOf yamlFormat.type;
        default = { };
        description = "Overrides for OMP's Mnemopi settings.";
      };
      hindsight = lib.mkOption {
        type = lib.types.attrsOf yamlFormat.type;
        default = { };
        description = "Overrides for OMP's Hindsight settings.";
      };
    };
    defaultPreset = lib.mkOption {
      type = lib.types.enum (builtins.attrNames modelPresets);
      default = "aperture";
      description = "Name of the model preset applied as the active OMP roles.";
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.memory.backend != "hindsight" || (cfg.memory.hindsight.apiUrl or null) != null;
        message = "optx.clanker.omp.memory.hindsight.apiUrl must be set for the Hindsight backend.";
      }
    ];

    home.packages = [
      omp
      pkgs.brave-origin
      pkgx.omp-claude-connectors-bridge.cli
      pkgx.split-commit.package
    ];

    # Keep long-running agents valid across upgrades and store garbage collection.
    home.sessionVariables.PUPPETEER_EXECUTABLE_PATH = "${config.home.profileDirectory}/bin/brave-origin";

    home.file = lib.mkMerge (
      map (lib.mapAttrs (_: file: file // { force = true; })) [
        {
          ".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" (
            {
              # bash
              async.enabled = true;
              async.printWake = false;
              async.widgets = true;
              bash.enabled = true;
              bash.allowCompoundCommands = false;
              bash.allowedEnvVars = [ ];
              bash.gitGuard = false;
              shellMinimizer.enabled = true;
              bash.autoBackground.enabled = true;
              bash.direnv = "off";
              bashInterceptor.enabled = true;
              launch.enabled = true;
              launch.persist = false;

              # subagents and delegation
              advisor.enabled = false;
              plan.enabled = false;
              task.isolation.enabled = false;
              task.eager = "default";
              task.autoParallel = "off";
              task.batch = true;
              task.steps = true;
              task.structured = true;
              task.enableEffort = true;
              task.perCallModel = "on";
              task.maxConcurrency = 4;
              task.workerThreads = 4;
              task.enableLsp = false;
              task.crossInstance = false;
              task.maxRecursionDepth = 1;
              task.maxRuntimeMs = 0;
              task.completionProbe = true;
              task.maxEffort = "high";
              task.prewalk = false;
              task.showResolvedModelBadge = true;
              todo.enabled = true;
              todo.reminders = true;
              todo.remindersMax = 2;
              todo.midRunNudges = "capped";
              todo.eager = "preferred";

              # context
              personality = "pragmatic";
              extendedContext = true;
              encourageEdits = true;
              recap.enabled = true;
              model.loopGuard.enabled = true;
              magicKeywords.enabled = false;
              compaction.enabled = true;
              compaction.experimentalContextManagement = true;
              compaction.midTurnEnabled = true;
              compaction.methodOrder = [
                "shake"
                "snapcompact"
                "remote"
                "soft"
                "handoff"
              ];
              compaction.modelThresholdsEnabled = true;
              compaction.handoffSaveToDisk = false;
              compaction.remoteStreamingV2Enabled = true;
              compaction.asyncEnabled = false;
              compaction.idleEnabled = false;
              compaction.supersedeReads = true;
              compaction.dropUseless = true;
              contextPromotion.enabled = false;
              ttsr.enabled = true;
              ttsr.judge = "on";
              ttsr.contextMode = "discard";
              ttsr.interruptMode = "always";
              ttsr.repeatMode = "once";
              ttsr.builtinRules = true;
              ttsr.disabledRules = [ ];
              steeringMode = "one-at-a-time";
              followUpMode = "one-at-a-time";
              interruptMode = "immediate";
              btw.inject = false;

              # tools
              tools.format = "auto";
              tools.maxTimeout = 0;
              tools.abortOnFabricatedResult = true;
              tools.speculativeExecution.enabled = false;
              tools.commands = true;
              tools.commandDocs = "catalog";
              tools.commandNotices = false;
              tools.approvalMode = "yolo";
              archive.enabled = true;
              astEdit.enabled = true;
              astGrep.enabled = true;
              checkpoint.enabled = false;
              commit.enabled = false;
              debug.enabled = true;
              glob.enabled = true;
              git.enabled = true;
              security.enabled = true;
              vault.enabled = false;
              disassembler.backend = "ghidra";
              ghidra.installDir = "${pkgs.ghidra}/lib/ghidra";
              ghidra.python = "${ghidraPython}/bin/python3";
              edit.mode = "hashline";
              edit.fuzzyMatch = false;
              edit.streamingAbort = true;
              edit.recoverInlineEdits = true;
              edit.blockAutoGenerated = true;
              edit.enforceSeenLines = true;
              readLineNumbers = true;
              read.renderMarkdown = false;
              read.toolResultPreview = false;
              read.summarize.enabled = true;
              read.summarize.prose = false;
              grep.enabled = true;
              grep.contextBefore = 5;
              grep.contextAfter = 5;
              find.enabled = "on";
              fetch.enabled = true;
              web_search.enabled = true;
              providers.webKeyless = true;
              exa.enabled = true;
              images.autoResize = true;
              images.describeForTextModels = false;
              images.urls.enabled = false;
              generate_image.enabled = false;
              eval.py = true;
              eval.js = true;
              eval.tools.enabled = true;
              eval.autoBackground.enabled = true;
              python.interpreter = lib.getExe pkgs.python3;
              lsp.enabled = false;
              lsp.lazy = false;
              lsp.diagnosticsOnWrite = false;
              github.enabled = true;
              github.cache.enabled = true;

              # browser and computer
              browser.enabled = true;
              browser.headless = true;
              browser.relay = false;
              browser.cmux = false;
              browser.tern = false;
              browser.webkit = false;
              browser.freezeOnTurnEnd = true;
              computer.enabled = true;
              computer.display = "all";
              computer.backgroundFallback = "takeover";

              # integrations
              commands.enableClaudeProject = false;
              commands.enableClaudeUser = false;
              commands.enableOpencodeProject = false;
              commands.enableOpencodeUser = false;
              contextFiles.extra = [ ];
              disabledProviders = [ "skillshare" ];
              marketplace.autoUpdate = "off";
              mcp.enableProjectConfig = false;
              mcp.startupTimeoutMs = 250;
              mcp.shared = true;
              mcp.idleStopMinutes = 5;
              mcp.evalNamespaces = false;
              mcp.builtinTransforms = true;
              mcp.renderMarkdownResults = true;
              mcp.notifications = false;
              mcp.notificationDebounceMs = 500;
              skills.enabled = true;
              skills.enableSkillCommands = true;
              skills.registryUrl = "http://0.0.0.0:0";
              skills.enableClaudeProject = false;
              skills.enableClaudeUser = false;
              skills.enableCodexUser = false;
              skills.enableAgentsProject = true;
              skills.enableAgentsUser = true;
              skills.enablePiProject = false;
              skills.enablePiUser = false;
              skills.customDirectories = [
                pkgx.split-commit.skills
                pkgx.omp-claude-connectors-bridge.skills
              ];
              extensions = [ pkgx.omp-claude-connectors-bridge.extension ];

              # models
              modelPresets = modelPresets;
              modelRoles = modelPresets.${cfg.defaultPreset}.modelRoles;
              defaultThinkingLevel = modelPresets.${cfg.defaultPreset}.defaultThinkingLevel;
              cycleOrder = [
                "smol"
                "default"
                "slow"
                "frontier"
              ];
              includeModelInPrompt = true;
              prewalk.enabled = false;
              prewalk.auto = "off";
              provider.appendOnlyContext = "on";
              providers.anthropic.slowMode = "auto";
              providers.fetch = "auto";
              providers.cacheRetention = "long";
              tier.openai = "none";
              tier.anthropic = "none";
              tier.google = "none";
              tier.subagent = "inherit";
              retry.usageAwareFallback = false;
              codexResets.autoRedeem5h = "no";
              codexResets.autoRedeemWeekly = "no";
              claudeResets.autoRedeem5h = "no";
              claudeResets.autoRedeemWeekly = "no";
              claudeResets.autoRedeemFable = "no";
              features.unexpectedStopDetection = "smart";
              retry.enabled = true;
              retry.maxRetries = 10;
              retry.waitForUsageReset = true;
              retry.modelFallback = false;

              # security
              secrets.enabled = true;
              dev.autoqa = false;
              dev.autoqaConsent = "denied";
              telemetry.otlpExportEnabled = false;
              providers.openai-codex.daybreak = false;
              providers.muse-code.storeResponses = false;
              spotlight.experiment.enabled = false;
              collab.autoStart = "off";
              collab.relayUrl = "wss://0.0.0.0:0";
              collab.webUrl = "https://0.0.0.0:0";
              share.serverUrl = "http://0.0.0.0:0";
              share.store = "blob";
              share.redactSecrets = true;
              stream.serverUrl = "http://0.0.0.0:0";

              # session
              session.worktreeScope = "repo";
              worktree.base = "~/projects";
              worktree.clone = true;
              worktree.cleanSource = false;
              worktree.onStart = "off";
              worktree.onExit = "keep";

              # speech
              speech.enabled = false;
              speechgen.enabled = false;
              stt.enabled = false;
              live.endpoint = "http://0.0.0.0:0/v1";

              # tui
              ask.enabled = true;
              ask.timeout = 0;
              ask.notify = "on";
              completion.notify = "on";
              error.notify = "off";
              startup.quiet = false;
              startup.showSplash = false;
              startup.setupWizard = false;
              startup.checkUpdate = false;
              startup.changelogMode = "summary";
              update.auto = false;
              doubleEscapeAction = "tree";
              composer.shape = "pi";
              composer.recallClearedDrafts = true;
              composer.predictionAlternatives = true;
              composer.predictions = true;
              display.cacheMissMarker = true;
              display.shimmer = "kitt";
              display.pinnedAgents = "collapsed";
              display.subagentLivePreview = true;
              display.smoothStreaming = true;
              display.hideToolActivity = false;
              display.showTokenUsage = false;
              display.showTurnTime = false;
              display.shellVisualization = true;
              display.collapseCompacted = true;
              hideThinkingBlock = true;
              showHardwareCursor = true;
              symbolPreset = "nerd";
              statusLine.preset = "custom";
              statusLine.separator = "powerline-thin";
              statusLine.compactThinkingLevel = true;
              statusLine.contextLine = "embedded";
              statusLine.sessionAccent = true;
              statusLine.transparent = false;
              statusLine.showHookStatus = true;
              statusLine.segmentOptions = { };
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
              terminal.showProgress = true;
              terminal.showImages = true;
              terminal.programStatus = true;
              pty.notify = "on";
              tui.maxInlineImageColumns = 100;
              tui.maxInlineImageRows = 20;
              tui.maxInlineImages = 8;
              tui.resizeScrollback = "rebuild";
              tui.textSizing = true;
              tui.colorfulMarkdown = true;
              tui.renderMermaid = true;
              tui.renderSvg = true;
              tui.renderEmbeds = true;
              tui.reactions = true;
              tui.codexResetFireworks = false;
              tui.titleState = true;
              tui.titleSpinner = "braille";
              tui.maxFps = 30;
              tui.mouse = false;
              tui.motion = "full";
              tui.imeSafeCursor = false;
              tui.vimMode = false;
              input.bareExitOnEmptySession = true;
              input.bareSlashCommands = false;
              treeFilterMode = "no-tools";
              tui.autoGraph = "smart";
              tui.hyperlinks = "always";
              tui.tight = true;
            }
            # memory
            // {
              autolearn.enabled = true;
              autolearn.autoContinue = true;
              memory.backend = cfg.memory.backend;
            }
            // lib.optionalAttrs (cfg.memory.backend == "mnemopi") {
              mnemopi = {
                scoping = "global";
                embeddingVariant = "en";
                autoRecall = true;
                recallRelevance = "off";
                autoRetain = true;
                polyphonicRecall = true;
                proactiveLinking = true;
                noEmbeddings = false;
                embeddingInputType = false;
                llmMode = "smol";
                retainEveryNTurns = 4;
                recallLimit = 12;
                recallContextTurns = 4;
              }
              // cfg.memory.mnemopi;
            }
            // lib.optionalAttrs (cfg.memory.backend == "hindsight") {
              hindsight = {
                scoping = "global";
                globalScope = true;
                autoRecall = true;
                autoRetain = true;
                retainEveryNTurns = 4;
                retainMode = "last-turn";
                retainOverlapTurns = 2;
                retainContext = "omp";
                recallBudget = "mid";
                recallContextTurns = 4;
                recallTypes = [
                  "world"
                  "experience"
                  "observation"
                ];
                mentalModelsEnabled = true;
                mentalModelAutoSeed = true;
              }
              // cfg.memory.hindsight;
            }
          );
        }

        {
          ".omp/agent/mcp.json".source = jsonFormat.generate "omp-mcp.json" {
            mcpServers = lib.mapAttrs (
              _: server:
              lib.hm.mcp.transformMcpServer {
                inherit server;
                extraTransforms = [ lib.hm.mcp.addType ];
                exclude = [ "serverUrl" ];
              }
            ) config.programs.mcp.servers;
          };

          ".omp/agent/models.yml".source = yamlFormat.generate "omp-models.yml" {
            providers.aperture = {
              baseUrl = "https://aperture.pony-clownfish.ts.net/v1";
              auth = "none";
              api = "openai-responses";
              discovery.type = "openai-models-list";
            };
          };
        }
      ]
    );
  };
}
