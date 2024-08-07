{
  boot = {
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
  };

  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;

    kmscon = {
      enable = true;
      hwRender = true;
    };

    displayManager.enable = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors = {};
  };

  environment.interactiveShellInit = ''
    systemctl --user import-environment PATH

    if uwsm check may-start && uwsm select; then
      exec systemd-cat -t uwsm_start uwsm start default
    fi
  '';

  xdg.dirs.config.uwsm.persist = true;
}
