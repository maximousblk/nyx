{ pkgs }: {
  bazarr = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/bazarr.svg";
    sha256 = "06chv4sr3bnz6jbj9h2a0d8s8lx8lp6b5rjd83scg3nbjqfyipa3";
  };
  crafty = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/crafty-controller.svg";
    sha256 = "0sfn9dzmzvr2kzwa35b1vxli85ad7kbljyg5s06r91mcd16x1rxn";
  };
  flaresolverr = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/flaresolverr.svg";
    sha256 = "1cvv2iybfyc9zcpvcphzp347gpv28fk5wnylwcf6z7bfrqdjij4z";
  };
  incus = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/zabbly/incus-ui-canonical/incus-0.21.6/public/assets/img/incus-logo.svg";
    sha256 = "1jp1wsw5sh42wsz1vg9wdn245qzm7ppp5726shbfc4f69zfv9zjn";
  };
  karakeep = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/karakeep-light.svg";
    sha256 = "06mic8gs6ca36rkwh20sq3ykw5dlqj2nsz760j78pfg5g2krhrrg";
  };
  omp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/can1357/oh-my-pi/main/assets/icon.svg";
    sha256 = "0qfgb6q4l152jq874l9sfc9n5wihk3zd71zis7inzwh6f1r1jw3j";
  };
  paseo = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/getpaseo/paseo/main/packages/website/public/logo.svg";
    sha256 = "1i3y03rij884bvfv972il7dc45gikhq4bngxzmgn62322a8kf0ps";
  };
  proxy = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/SagerNet/sing-box/testing/docs/assets/icon.svg";
    sha256 = "0jsp5kis87cdg141gaff1jsbxfimw117qd0yimy5ygkrnhmli6z5";
  };
  rustfs = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/rustfs.svg";
    sha256 = "0fwadkbgkax2gj0vzsv6pw5l5in73sglaxl05vkqvpa73rz2kaqg";
  };
  signoz = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/signoz.svg";
    sha256 = "1k60vdiwd8gifag1rfany9bkrip73q3a76rcx4dpyz8qx7ry3m3a";
  };
  sunshine = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/sunshine.svg";
    sha256 = "0fhg4vx9x8b4ayn7micc6v3bc8a3kcz1pc4ld3v8qn3dgcmlqyqv";
  };
  tailscale = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/tailscale-light.svg";
    sha256 = "1sas4cg0rk0phgdabs70jx5kg332p9lf94qdki5n7vg6asxkziqz";
  };
  zerobyte = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/zerobyte.svg";
    sha256 = "1pn9shc37fv0dxnv5bsk1va799z0ax389n56p6ayj4li2yv1jiys";
  };
}
