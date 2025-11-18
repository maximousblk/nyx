{ pkgs, ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."99-rnnoise" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "media.name" = "Studio Voice Source";
            "node.description" = "Studio Voice Source";

            "audio.rate" = 48000;
            "audio.position" = "[ MONO ]";

            "playback.props" = {
              "node.name" = "playback.studio_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
            "capture.props" = {
              "node.name" = "capture.studio_sink";
              "node.passive" = true;
              "audio.rate" = 48000;
            };
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)" = 20.0;
                    "VAD Grace Period (ms)" = 500;
                    "Retroactive VAD Grace (ms)" = 100;
                  };
                }
              ];
            };
          };
        }
      ];
    };

    wireplumber.extraConfig = {
      "10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hfp_hf"
            "a2dp_sink"
            "a2dp_source"
          ];
        };
      };

      "11-disable-suspension" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input.*"; }
              { "node.name" = "~alsa_output.*"; }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };

      "12-deprioritize-garbage" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~.*HDMI.*"; }
              { "node.name" = "~.*pro-output.*"; }
            ];
            actions = {
              update-props = {
                "priority.driver" = 50;
                "priority.session" = 50;
              };
            };
          }
        ];
      };
    };
  };
}
