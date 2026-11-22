{ ly }:
ly.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./autologin-delay.patch ];
})
