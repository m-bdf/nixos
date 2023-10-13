{
  nixConfig = {
    extra-substituters = [ "https://m-bdf.cachix.org" ];
    extra-trusted-public-keys =
      [ "m-bdf.cachix.org-1:7Uae6pLA5GHDKSM1vvp0jX/8D5jRJOqXxL/dFIef55s=" ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@ inputs:

  with nixpkgs.lib;

  {
    lib = extend (final: prev: {
      mkAliasOptionModule = mkRenamedOptionModule;

      listDir = dir: mapAttrs' (entry: type:
        nameValuePair (head (splitString "." entry)) /${dir}/${entry}
      ) (builtins.readDir dir);
    });

    nixosModules = mapAttrs (name: path:
      setDefaultModuleLocation path path
    ) (self.lib.listDir ./config);

    nixosConfigurations =
    let
      mkSystem = name: modules: nixosSystem {
        specialArgs = inputs // { inherit (self) lib; };
        modules = attrValues self.nixosModules;
        extraModules = modules ++ [ ./hardware/${name}.nix ];
      };
    in
      mapAttrs mkSystem {
        vbox = [];
        qemu = [];

        t480 = with nixos-hardware.nixosModules; [
          lenovo-thinkpad-t480
          common-gpu-nvidia-disable
          common-pc-ssd
        ];
      };

    checks = import ./tests.nix inputs;
  };
}
