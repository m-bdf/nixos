{ inputs, config, lib, ... }:

with lib;

let
  persistableFileModule = { config, ... }: {
    options.persist = mkEnableOption "persisting this directory";
    config.enable = mkIf config.persist false;
  };

  persistableFilesOption = mkOption {
    type = with types;
      attrsOf (submodule persistableFileModule);
  };
in

{
  options = {
    xdg = {
      cacheFile = persistableFilesOption;
      configFile = persistableFilesOption;
      dataFile = persistableFilesOption;
      stateFile = persistableFilesOption;
    };

    home.file = persistableFilesOption // {
      apply = mapAttrs (name: cfg: cfg //
        optionalAttrs (!hasPrefix "/" cfg.target) {
          target = removePrefix "/" # make `force` work
            "${config.home.homeDirectory}/${cfg.target}";
        }
      );
    };
  };

  config = {
    xdg.enable = true;

    lib.bash = mkForce {
      initHomeManagerLib = ''
        source ${inputs.home-manager}/lib/bash/*
        test $(basename $0) = activate || HOME=/
      '';
    };

    home.file = {
      "Documents" = {
        persist = true;
        executable = true;
      };
      "Downloads".persist = true;
    };
  };
}
