# Ly with cancellable autologin

`default.nix` extends Nixpkgs' Ly with `autologin-delay.patch`, preserving existing
patches and build settings. `pkgx/default.nix` imports it directly to preserve the
upstream `.override { x11Support = ...; }` interface; Victus selects `pkgx.ly`
through `services.displayManager.ly.package`.

The patch targets Ly 1.5.0. Startup autologin becomes a one-shot, hard-coded
five-second monotonic deadline owned by `main.zig`. The normal greeter draws and
handles terminal events throughout the wait, with no new messages or visual
changes. Any key cancels the automatic attempt and is consumed after normal
activity bookkeeping; subsequent keys use normal login and session selection.
Resize events retain their original handling and do not reset the deadline.

The terminal loop exposes generic timeout and key-consumption callbacks; it knows
nothing about authentication. Its native input wait uses the earlier of the
widget timeout and application timeout. There is no separate event loop, polling
interval, raw-event reader, countdown UI, or new configuration setting. The
application clears its deadline before invoking existing PAM authentication, so
failure or logout does not repeat the automatic attempt. Password-protected
keyrings still require their normal post-login unlock prompt.

Build and test the package independently when updating Ly. Restarting the live
display manager terminates the graphical session. Isolated pseudo-terminal smoke
checks verified cancellation without authentication, one idle attempt after
5.002 seconds, native resize handling with the same deadline, and ordinary
startup without autologin. The greeter remained alive after each scenario; the
autologin tests used a nonexistent PAM service, not successful real login.
