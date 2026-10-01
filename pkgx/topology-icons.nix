{ pkgs }:
let
  stripSvgMetadata =
    name: src:
    pkgs.runCommand name { } ''
      ${pkgs.gnused}/bin/sed -E 's|<title>[^<]*</title>||g; s|<desc>[^<]*</desc>||g' ${src} > "$out"
    '';
in
{
  bazarr = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/bazarr.svg";
    sha256 = "06chv4sr3bnz6jbj9h2a0d8s8lx8lp6b5rjd83scg3nbjqfyipa3";
  };
  dnscrypt-proxy = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-proxy/master/logo.svg";
    sha256 = "sha256-kGZNNa5HqJqI1y1cqDL85PO4t3ip62n5RtyBDt+eE2w=";
  };
  crafty = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/crafty-controller.svg";
    sha256 = "0sfn9dzmzvr2kzwa35b1vxli85ad7kbljyg5s06r91mcd16x1rxn";
  };
  flaresolverr = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/flaresolverr.svg";
    sha256 = "1cvv2iybfyc9zcpvcphzp347gpv28fk5wnylwcf6z7bfrqdjij4z";
  };
  immich = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/immich.svg";
    sha256 = "sha256-pdSkOJnmP/x+lyRgNPf2PN/cQQqoA8VxPVRSkGAcTYk=";
  };
  flux = stripSvgMetadata "flux-icon.svg" (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fluxcd/website/main/static/img/flux-icon.svg";
      sha256 = "1w4r7k1l642skjpyybr56nc90l4nlwd0v8bqk9d873c8pd6jmgzi";
    }
  );
  headlamp = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/headlamp.svg";
    sha256 = "1lz262r09lvgprk8s02kj2mcrxc5qyvgr9qw0xhha8vz03gl8ivq";
  };
  incus = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/zabbly/incus-ui-canonical/incus-0.21.6/public/assets/img/incus-logo.svg";
    sha256 = "1jp1wsw5sh42wsz1vg9wdn245qzm7ppp5726shbfc4f69zfv9zjn";
  };
  jellyfin = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/jellyfin.svg";
    sha256 = "sha256-m/uHU9mDEDiJqNwkhzi/0FbgP1JzTi1u60pcWSUUjBA=";
  };
  k3s = stripSvgMetadata "k3s-icon.svg" (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/cncf/artwork/master/projects/k3s/icon/color/k3s-icon-color.svg";
      sha256 = "02dgp0c8rspicgrdbahrv1p44vsvhwkyc0qpf011qmv5md0i68y6";
    }
  );
  karakeep = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/karakeep-light.svg";
    sha256 = "06mic8gs6ca36rkwh20sq3ykw5dlqj2nsz760j78pfg5g2krhrrg";
  };
  nfs = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/linux.svg";
    sha256 = "sha256-SYq0Rw2xZsiqdUGu5BXLwdjtv7Ym0hYbPoHUqxghmPQ=";
  };
  omp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/collab-web/public/favicon.svg";
    sha256 = "01gyd4vlx9ydja7pcdx0kyc6mcixf0cfqk0w490i75i41id9f6cl";
  };
  openbao = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/openbao.svg";
    sha256 = "1r1hd4m1vb37jj10cfij1sqiq3ydfvdfa5wgdkwzj8608b2rd10y";
  };
  opentelemetry = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/opentelemetry.svg";
    sha256 = "14pv7hpvi93amki5iq37592qkkhxypcgfqfqscw2qyiiyk9273jz";
  };
  orca = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/stablyai/orca/main/resources/icon.png";
    sha256 = "1ky40i3zlcjs6qfw959q047kjrs7rahcvy5hf1xs5dcmsrbabqvg";
  };
  paseo = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/getpaseo/paseo/main/packages/website/public/logo.svg";
    sha256 = "1i3y03rij884bvfv972il7dc45gikhq4bngxzmgn62322a8kf0ps";
  };
  paperless = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/paperless-ngx.svg";
    sha256 = "sha256-mkjYejHZOsodNNUqUQ+3rdWRn0nTEntZWhA159XK6/Q=";
  };
  proxy = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/SagerNet/sing-box/testing/docs/assets/icon.svg";
    sha256 = "0jsp5kis87cdg141gaff1jsbxfimw117qd0yimy5ygkrnhmli6z5";
  };
  radar = builtins.fetchurl {
    url = "https://radarhq.io/radar/icon-512.png";
    sha256 = "0qb2n2g5f3v5bzj7c3qiphd53ihqj208f6agh002fhaf5b3l1q43";
  };
  rustfs = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/rustfs.svg";
    sha256 = "0fwadkbgkax2gj0vzsv6pw5l5in73sglaxl05vkqvpa73rz2kaqg";
  };
  signoz = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/signoz.svg";
    sha256 = "1k60vdiwd8gifag1rfany9bkrip73q3a76rcx4dpyz8qx7ry3m3a";
  };
  scrutiny = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/scrutiny.svg";
    sha256 = "0hl55xplhkwjj8xd84r7h08vbz6if5mf7is1nxsz5a86xbkccm32";
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
