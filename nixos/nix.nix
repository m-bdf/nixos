{ inputs, options, config, lib, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.home = lib.mkOption {
    type = options.home-manager.users.type.nestedTypes.elemType;
  };

  config = {
    nix = {
      channel.enable = false;
      inherit (config.home.nix) settings extraOptions;
    };

    system = {
      disableInstallerTools = true;
      stateVersion = lib.trivial.release;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      startAsUserService = true;
      extraSpecialArgs.name = "user";
      users.user = lib.mkAliasDefinitions options.home;
    };

    systemd.user.services = {
      home-manager.unitConfig = {
        DefaultDependencies = false;
      };
      nixos-activation.unitConfig = {
        DefaultDependencies = false;
        Before = [ "dbus.socket" ];
      };
    };
  };
}
