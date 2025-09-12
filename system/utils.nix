{ config, ... }:

{
  options.system.path = config.home.lib.mkPathOption;

  config.documentation.man.generateCaches = false;
}
