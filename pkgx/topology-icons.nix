{ pkgs }:
let
  stripSvgMetadata =
    name: src:
    pkgs.runCommand name { } ''
      ${pkgs.gnused}/bin/sed -E 's|<title>[^<]*</title>||g; s|<desc>[^<]*</desc>||g' ${src} > "$out"
    '';
in
{
  dashbrr = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/autobrr/dashbrr/v0.7.0/.github/assets/logo.png";
    sha256 = "027ybg4cwjs00vq4qhw114v6jw4x0gv1fw54hgyapg1pc0fl3cay";
  };
  bazarr = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/bazarr.svg";
    sha256 = "0d4rh8z8g3jgrrcq7dnm2569i6gkigwnx7dmn5802mrzvwxzgvgb";
  };
  dnscrypt-proxy = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-proxy/9c73f44fec9952347a8fe123cc1554f84cc44a5f/logo.svg";
    sha256 = "0v0kkvghx0fw8vwnksx9g2vviwz4zhrahp1dsy49ma27mqslsrlh";
  };
  crafty = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/crafty-controller.svg";
    sha256 = "1c11cxd86y3snj1a2zmbqny7fzzwwmp062z0iq36nw6b129kw1wd";
  };
  flaresolverr = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/flaresolverr.svg";
    sha256 = "18dwvs8z3l7jiga49n8vim0sw14lx2isaqdinyfsn9p8fscl2kfb";
  };
  immich = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/immich.svg";
    sha256 = "0p54gb03wn7z4ijgbd0h46hfnjn97ly6ap20vsqg7wjx8i5sjl5m";
  };
  headlamp = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/headlamp.svg";
    sha256 = "14pr5yavhx2qpks5h9wvrxj3r4rbh22zryhzc6imk6cjd2p15b1n";
  };
  incus = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/zabbly/incus-ui-canonical/incus-0.21.6/public/assets/img/incus-logo.svg";
    sha256 = "1jp1wsw5sh42wsz1vg9wdn245qzm7ppp5726shbfc4f69zfv9zjn";
  };
  jellyfin = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/jellyfin.svg";
    sha256 = "07zkim8yniggkk8l8lzdg78zgqch9w293l7fxd7jb0kgpd743j0j";
  };
  k3s = stripSvgMetadata "k3s-icon.svg" (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/cncf/artwork/bffd512a8b625f15cf5f8e0427469380b5768e90/projects/k3s/icon/color/k3s-icon-color.svg";
      sha256 = "02dgp0c8rspicgrdbahrv1p44vsvhwkyc0qpf011qmv5md0i68y6";
    }
  );
  karakeep = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/karakeep-light.svg";
    sha256 = "0lk1yspsrw8a9ycscjrdnn2l6j36bncjpvg19an4rhw6854n1sd5";
  };
  nfs = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/linux.svg";
    sha256 = "0hl8y92qly7jg92j2hp24ymnvmczk3hn1mih4m64s5zhnbs67kq2";
  };
  omp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/can1357/oh-my-pi/aa5f045f98a90f5c7bbc6b091f1e97e42263194d/packages/collab-web/public/favicon.svg";
    sha256 = "01gyd4vlx9ydja7pcdx0kyc6mcixf0cfqk0w490i75i41id9f6cl";
  };
  openbao = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/openbao.svg";
    sha256 = "0g40lfbj6iyxx3ys6hz22ldqfsz72mfmr095j144bddlikjkd7bb";
  };
  opentelemetry = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/opentelemetry.svg";
    sha256 = "1c97mbhapzjc1h7ab5k2gjx780rmgibxd265l3yahcs2iaj5k4n8";
  };
  paseo = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/getpaseo/paseo/d13438ba50ed74c0d9057370b5f5c781aee0f687/packages/website/public/logo.svg";
    sha256 = "1i3y03rij884bvfv972il7dc45gikhq4bngxzmgn62322a8kf0ps";
  };
  paperless = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/paperless-ngx.svg";
    sha256 = "1f1diysvmjvvl526w0j4hdb4lpzxmjq4nrxagi3pl9n34f1nlnk6";
  };
  pi-pocket = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/TannerMidd/pi-pocket/5d009fa4d1e2b69db54f05e04f750a6f2e591bb1/web/icon-512.png";
    sha256 = "0mpmvwj8lhqb3p4zq06giw4l08cj3h28jl4qdz7kmam5dmvi0z6h";
  };
  proxy = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/SagerNet/sing-box/a13dbe1f785f66c86acbf3985c33fdafea0cbfd6/docs/assets/icon.svg";
    sha256 = "0jsp5kis87cdg141gaff1jsbxfimw117qd0yimy5ygkrnhmli6z5";
  };
  qbittorrent = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/qbittorrent.svg";
    sha256 = "121h5zz7f7wz39cl302m1rfsmvv26m7akcpig0l2hwzz7g8m0sks";
  };
  rustfs = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/rustfs.svg";
    sha256 = "0sd4kr563d8p5fgmzkyzygs464a6knq312shvymr48y37028fabs";
  };
  signoz = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/signoz.svg";
    sha256 = "13g82fkily1plkxd25am63sbks26fn1sjnxvsa44ng9m2gndj4yz";
  };
  scrutiny = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/scrutiny.svg";
    sha256 = "0apzhi3irgcflzkswb20nl1i3pqzc0x0ah3nczqr3yyiqbfklwlb";
  };
  sunshine = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/sunshine.svg";
    sha256 = "0r7mab8lqi5p73lfww18k660k67hafd8ggbxzrcw3s0jzvh80z5x";
  };
  tailscale = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/tailscale-light.svg";
    sha256 = "0ihb9rxjl3zl4ibb1cs5y8y8jf4bbbvrmcd8mm17bjcia0073rc6";
  };
  zerobyte = builtins.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/selfhst/icons@9b7e0f8b76d5e9542d181c914c897beb695de402/svg/zerobyte.svg";
    sha256 = "0p7qnp363w6ch8gcrqikzcmkv1bdcm0s3vbjwri63kwgs715xj5c";
  };
}
