{
  nixConfig = {
    sandbox = "relaxed";
    build-users-group = "";

    extra-substituters = [ "https://m-bdf.cachix.org" ];
    extra-trusted-public-keys =
      [ "m-bdf.cachix.org-1:7Uae6pLA5GHDKSM1vvp0jX/8D5jRJOqXxL/dFIef55s=" ];
  };

  inputs = {
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixos-unstable";

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    impermanence.url = "github:Mic92/impermanence/userborn-support";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gtklock.url = "github:fugidev/nixpkgs/gtklock-module";
  };

  outputs = { self, nixpkgs, ... }@ inputs:

  with self.lib;

  {
    lib = nixpkgs.lib.extend (final: prev: {
      mkAliasOptionModule = mkRenamedOptionModule;

      listDir = dir: mapAttrs' (entry: type:
        nameValuePair (head (splitString "." entry)) /${dir}/${entry}
      ) (builtins.readDir dir);
    });

    nixosModules = mapAttrs (name: path:
      setDefaultModuleLocation path path
    ) (listDir ./config);

    nixosConfigurations.nixos = nixosSystem {
      specialArgs = self;
      modules = attrValues self.nixosModules;
    };

    checks = import ./tests.nix inputs;
  };
}
