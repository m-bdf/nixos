{ pkgs, ... }:

let
  session-run = pkgs.writeShellScriptBin "session-run" ''
    unit=session-''${XDG_SESSION_ID:?
      "Can't create a session inside another session"}

    XDG_RUNTIME_DIR+=/$unit
    trap "rm --recursive --force $XDG_RUNTIME_DIR" EXIT
    mkdir --mode=0700 --parents $XDG_RUNTIME_DIR

    printf '%s ' "$@" > $XDG_RUNTIME_DIR/.cmd
    vars=XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS
    env > $XDG_RUNTIME_DIR/.env

    cmd='
      echo $INVOCATION_ID > $XDG_RUNTIME_DIR/.iid
      init --user --unit=session.service --log-target=journal
    '
    eval systemd-run --user --unit=$unit --pty --pipe \
      --setenv={$vars=unix:path=$XDG_RUNTIME_DIR/bus} \
      --service-type=notify --wait --collect sh -c '"$cmd"'

    status=$?
    journalctl _SYSTEMD_INVOCATION_ID=$(<$XDG_RUNTIME_DIR/.iid)
    exit $status
  '';
in

{
  environment.systemPackages = [ session-run ];

  systemd.user.services.session = {
    serviceConfig = {
      EnvironmentFile = "%t/.env";
      ExecStart = "/bin/sh %t/.cmd";
    };
    unitConfig = {
      SuccessAction = "exit";
      FailureAction = "exit";
    };
  };
}
