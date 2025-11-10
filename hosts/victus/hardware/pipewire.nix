{ pkgs, ... }:
let
  deepFilterConfig = pkgs.writeText "99-deepfilternet.conf" (
    builtins.toJSON {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "media.name" = "Studio Voice Source";
            "node.description" = "Studio Voice Source";
            "audio.rate" = 48000;
            "audio.position" = "[ MONO ]";
            "playback.props" = {
              "media.class" = "Audio/Source";
            };
            "capture.props" = {
              "node.target" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source";
              "audio.rate" = 48000;
            };
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_stereo";
                  control = {
                    "VAD Threshold (%)" = 80.0;
                    "VAD Grace Period (ms)" = 500;
                    "Retroactive VAD Grace (ms)" = 200;
                  };
                }
              ];

            };
            # "capture.props" = {
            #   "node.name" = "capture.rnnoise_source";
            #   "node.passive" = true;
            #   "audio.rate" = 48000;
            # };
            # "playback.props" = {
            #   "node.name" = "rnnoise_source";
            #   "media.class" = "Audio/Source";
            #   "audio.rate" = 48000;
            # };
          };
        }
      ];
    }
  );

  wireplumberDefaultRule = pkgs.writeText "51-set-default-source.lua" ''
    rule = {
      matches = {
        {
          { "metadata.name", "equals", "default" },
        },
      },
      actions = {
        ["set-default"] = {
          ["Audio/Source"] = "Studio Voice Source",
        },
      },
    }

    table.insert(metadata.rules, rule)
  '';
in
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      configPackages = [
        (pkgs.runCommand "wireplumber-default-mic-rule" { } ''
          mkdir -p $out/share/wireplumber/main.lua.d
          cp ${wireplumberDefaultRule} $out/share/wireplumber/main.lua.d/
        '')
      ];
    };

    configPackages = [
      (pkgs.runCommand "pipewire-deepfilter-config" { } ''
        mkdir -p $out/share/pipewire/pipewire.conf.d
        cp ${deepFilterConfig} $out/share/pipewire/pipewire.conf.d/
      '')
    ];
  };
}
