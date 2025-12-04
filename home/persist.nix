{ config, lib, ... }:

with lib;

let
  persistableFileModule = { config, ... }: {
    options.persist = mkEnableOption "persisting this directory";
    config.enable = mkDefault (!config.persist);
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

    home = {
      activation = {
        unsetHome = hm.dag.entryBefore
          [ "linkGeneration" ] "HOME=";
        resetHome = hm.dag.entryBetween
          [ "batCache" ] [ "linkGeneration" ]
          "HOME=${config.home.homeDirectory}";
      };

      file = {
        "Documents" = {
          persist = true;
          executable = true;
        };
        "Downloads".persist = true;
      };
    };
  };
}
