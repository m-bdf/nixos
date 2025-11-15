{ inputs, options, config, lib, pkgs, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "home" ] [ "home-manager" "config" ])
  ];

  options = {
    build.activationPackage = config.home.lib.mkToplevelOption;
    environment.path = config.home.lib.mkPathOption;
  };

  config = {
    user = {
      userName = "mae";
      shell = pkgs.fish;
    };

    system.stateVersion = lib.last
      options.system.stateVersion.type.functor.payload.values;

    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs.inputs = inputs;
    };

    home = lib.mapAttrsRecursive (_: lib.mkForce) {
      nix.settings = {
        use-xdg-base-directories = false;
        auto-optimise-store = false;
      };
      programs.nh.enable = false;
    };

    environment.sessionVariables =
    let
      dnshack = pkgs.callPackage inputs.dnshack {};
    in {
      DNSHACK_RESOLVER_CMD = dnshack + /bin/dnshackresolver;
      LD_PRELOAD = dnshack + /lib/libdnshackbridge.so;
    };
  };
}
