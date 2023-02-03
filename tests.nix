{ self, nixpkgs, ... }@ inputs:

with nixpkgs.lib;

let
  configTests =
    mapAttrsToList (name: system: {
      ${system.pkgs.system}.${name} =
        (system.extendModules {
          modules = [ ./asserts.nix ];
        }).config.system.build.toplevel;
    }) self.nixosConfigurations;

  mkVmTest = platform: name: script:
  let
    test = nixos.runTest rec {
      inherit name;
      node.specialArgs = inputs;
      hostPkgs = nixpkgs.legacyPackages.${platform};

      nodes.machine = {
        nixpkgs.pkgs = hostPkgs;
        imports = attrValues self.nixosModules;
        virtualisation.writableStore = false;
      };

      testScript = ''
        machine.wait_for_unit("default.target")
        ${readFile script}
      '';
    };
  in
    nameValuePair test.name test;

  vmTests = genAttrs [ "x86_64-linux" "aarch64-linux" ]
    (platform: mapAttrs' (mkVmTest platform) (self.lib.listDir ./tests));
in

foldl' recursiveUpdate {} (configTests ++ [vmTests])
