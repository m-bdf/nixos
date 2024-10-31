{
  nixConfig = {
    extra-substituters = [ "https://m-bdf.cachix.org" ];
    extra-trusted-public-keys =
      [ "m-bdf.cachix.org-1:7Uae6pLA5GHDKSM1vvp0jX/8D5jRJOqXxL/dFIef55s=" ];

    sandbox = "relaxed";
    build-users-group = "";
  };

  inputs = {
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    impermanence.url = "github:Mic92/impermanence/userborn-support";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dracula-fuzzel = {
      url = "github:dracula/fuzzel";
      flake = false;
    };

    dracula-kitty = {
      url = "github:dracula/kitty";
      flake = false;
    };

    zig.url = "github:ExpidusOS/nixpkgs/feat/zig-bootstrap";
    kmscon.url = "github:m-bdf/nixpkgs/kmscon-login-session-tracking";
  };

  outputs = { self, nixpkgs, nixos-facter-modules, ... }@ inputs:

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
    ) (listDir ./config)
    //
    {
      hardware = {
        imports = [ nixos-facter-modules.nixosModules.facter ];

        facter.reportPath =
        let
          pkgs = import nixpkgs {}; # impure
        in
          pkgs.runCommandLocal "report" { __noChroot = true; } # TODO: __impure
            "(${getExe pkgs.nixos-facter} --hardware all || echo {}) > $out";
      };
    };

    nixosConfigurations = {
      nixos = nixosSystem {
        system = builtins.currentSystem;
        specialArgs = self;
        modules = attrValues self.nixosModules;
      };

      vm = nixosSystem {
        specialArgs = self;
        modules = [
          ({ modulesPath, ... }:

          {
            imports = with self.nixosModules; [
              hardware mounts dirs user
              /${modulesPath}/virtualisation/qemu-vm.nix
            ];

            virtualisation = {
              cores = 8;
              memorySize = 8000;
              diskImage = null;
              diskSize = 8000;
            };

            environment.etc.nixos.source = ./.;
          })
        ];
      };
    };

    checks = import ./tests.nix inputs;
  };
}
