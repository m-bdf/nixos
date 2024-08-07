{ lib, pkgs, ... }:

{
  boot = {
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
  };

  services = {
    kmscon = {
      enable = true;
      hwRender = true;
    };

    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;

    dbus.implementation = "broker";

    displayManager.enable = true;
  };

  environment.loginShellInit = ''
    systemctl --user import-environment PATH
    uwsm=${lib.getExe pkgs.uwsm}

    if $uwsm check may-start && env XDG_CONFIG_HOME=/tmp $uwsm select; then
      exec systemd-cat -t uwsm_start env XDG_CONFIG_HOME=/tmp $uwsm start default
    fi
  '';
}
