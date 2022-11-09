{ pkgs, ... }:

let
  session-run = pkgs.writeShellScriptBin "session-run" ''
    XDG_RUNTIME_DIR+=/session-$$
    trap "rm --recursive --force $XDG_RUNTIME_DIR" EXIT
    mkdir --parents $XDG_RUNTIME_DIR

    printf '%q ' "$@" > $XDG_RUNTIME_DIR/cmd
    vars=XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS
    eval env --unset={$vars} > $XDG_RUNTIME_DIR/env

    eval systemd-run --user --unit=session-$$ --collect \
      --setenv={$vars=unix:path=$XDG_RUNTIME_DIR/bus} \
      --pty init --user --unit=session.service

    journalctl --user-unit=session-$$ --boot
  '';
in

{
  environment.systemPackages = [ session-run ];

  systemd.user.services.session = {
    serviceConfig = {
      EnvironmentFile = "%t/env";
      ExecStart = "/bin/sh %t/cmd";
    };
    unitConfig = {
      SuccessAction = "exit";
      FailureAction = "exit";
    };
  };
}
