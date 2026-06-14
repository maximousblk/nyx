{ pkgs, ... }: {
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraLadspaPackages = [
      pkgs.deepfilternet
      pkgs.lsp-plugins
    ];

    extraConfig.pipewire = {
      "91-global-clock" = {
        "context.properties" = {
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 1024;
        };
      };

      "99-studio-voice" = {
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
                "node.latency" = "2048/48000";
              };
              "capture.props" = {
                "node.name" = "capture.studio_sink";
                "node.passive" = true;
                "audio.rate" = 48000;
                "node.latency" = "2048/48000";
              };
              "filter.graph" = {
                nodes = [
                  {
                    type = "ladspa";
                    name = "eq";
                    plugin = "lsp-plugins-ladspa";
                    label = "http://lsp-plug.in/plugins/ladspa/para_equalizer_x16_mono";
                    control = {
                      "Input gain (G)" = 0.75;
                      "Output gain (G)" = 1.0;
                      "Equalizer mode" = 0;
                      "Filter type 0" = 2;
                      "Frequency 0 (Hz)" = 110;
                      "Gain 0 (G)" = 1;
                      "Filter Width 0 (oct)" = 0.5;
                      "Filter type 1" = 1;
                      "Frequency 1 (Hz)" = 180;
                      "Gain 1 (G)" = 0.9;
                      "Filter Width 1 (oct)" = 1.0;
                      "Filter type 2" = 1;
                      "Frequency 2 (Hz)" = 350;
                      "Gain 2 (G)" = 0.92;
                      "Filter Width 2 (oct)" = 1.0;
                      "Filter type 3" = 1;
                      "Frequency 3 (Hz)" = 3000;
                      "Gain 3 (G)" = 1.12;
                      "Filter Width 3 (oct)" = 1.2;
                      "Filter type 4" = 3;
                      "Frequency 4 (Hz)" = 7000;
                      "Gain 4 (G)" = 0.9;
                      "Filter Width 4 (oct)" = 1.0;
                      "Filter type 5" = 4;
                      "Frequency 5 (Hz)" = 11000;
                      "Gain 5 (G)" = 1;
                      "Filter Width 5 (oct)" = 0.6;
                    };
                  }
                  {
                    type = "ladspa";
                    name = "deepfilter";
                    plugin = "libdeep_filter_ladspa";
                    label = "deep_filter_mono";
                    control = {
                      "Attenuation Limit (dB)" = 100;
                      "Min processing threshold (dB)" = -8;
                      "Max ERB processing threshold (dB)" = 30;
                      "Max DF processing threshold (dB)" = 20;
                      "Min Processing Buffer (frames)" = 1;
                      "Post Filter Beta" = 0.02;
                    };
                  }
                  {
                    type = "ladspa";
                    name = "gate";
                    plugin = "lsp-plugins-ladspa";
                    label = "http://lsp-plug.in/plugins/ladspa/gate_mono";
                    control = {
                      "Input gain (G)" = 1;
                      "Output gain (G)" = 1.33;
                      "Sidechain lookahead (ms)" = 8;
                      "Sidechain reactivity (ms)" = 60;
                      "Sidechain preamp (G)" = 1;
                      "High-pass filter mode" = 0;
                      "High-pass filter frequency (Hz)" = 10;
                      "Low-pass filter mode" = 0;
                      "Low-pass filter frequency (Hz)" = 20000;
                      "Hysteresis" = 0;
                      "Curve threshold (G)" = 0.08;
                      "Curve zone size (G)" = 0.04;
                      "Hysteresis threshold (G)" = 0.001;
                      "Hysteresis zone size (G)" = 0.001;
                      "Attack (ms)" = 12;
                      "Release (ms)" = 100;
                      "Hold time (ms)" = 80;
                      "Reduction (G)" = 0.00025119;
                      "Makeup gain (G)" = 1;
                      "Dry gain (G)" = 0;
                      "Wet gain (G)" = 1;
                      "Dry/Wet balance (%)" = 100;
                    };
                  }
                  {
                    type = "ladspa";
                    name = "comp";
                    plugin = "lsp-plugins-ladspa";
                    label = "http://lsp-plug.in/plugins/ladspa/compressor_mono";
                    control = {
                      "Input gain (G)" = 1;
                      "Output gain (G)" = 1.3;
                      "Sidechain lookahead (ms)" = 2;
                      "Sidechain reactivity (ms)" = 120;
                      "High-pass filter mode" = 1;
                      "High-pass filter frequency (Hz)" = 80;
                      "Attack threshold (G)" = 0.3;
                      "Attack time (ms)" = 5;
                      "Release threshold (G)" = 0.15;
                      "Release time (ms)" = 80;
                      "Ratio" = 3;
                      "Knee (G)" = 0.5;
                      "Makeup gain (G)" = 1;
                      "Dry/Wet balance (%)" = 100;
                    };
                  }
                  {
                    type = "ladspa";
                    name = "limit";
                    plugin = "lsp-plugins-ladspa";
                    label = "http://lsp-plug.in/plugins/ladspa/limiter_mono";
                    control = {
                      "Input gain (G)" = 1;
                      "Output gain (G)" = 1;
                      "Operating mode" = 0;
                      "Threshold (G)" = 0.95;
                      "Knee level (G)" = 1;
                      "Lookahead (ms)" = 3;
                      "Attack time (ms)" = 1;
                      "Release time (ms)" = 15;
                    };
                  }
                ];
                inputs = [ "eq:Input" ];
                outputs = [ "limit:Output" ];
                links = [
                  {
                    output = "eq:Output";
                    input = "deepfilter:Audio In";
                  }
                  {
                    output = "deepfilter:Audio Out";
                    input = "gate:Input";
                  }
                  {
                    output = "gate:Output";
                    input = "comp:Input";
                  }
                  {
                    output = "comp:Output";
                    input = "limit:Input";
                  }
                ];
              };
            };
          }
        ];
      };
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
