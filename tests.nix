{ self, systems, nixpkgs, ... }:

with self.lib;

let
  configTests =
    mapAttrsToList (name: system: {
      ${system.pkgs.stdenv.system}.${name} =
        (system.extendModules {
          modules = [ ./asserts.nix ];
        }).config.system.build.toplevel;
    }) self.nixosConfigurations;

  mkVmTest = platform: name: script:
  let
    test = nixos.runTest {
      inherit name;
      hostPkgs = nixpkgs.legacyPackages.${platform};
      node.specialArgs = self;

      nodes.machine = {
        imports = attrValues self.nixosModules;
        virtualisation.writableStore = false;
        users.users.user.name = mkForce "user";
      };

      testScript = ''
        machine.wait_for_unit("default.target")
        ${readFile script}
      '';
    };
  in
    nameValuePair test.name test;

  vmTests = genAttrs (import systems)
    (platform: mapAttrs' (mkVmTest platform) (listDir ./tests));
in

foldl' recursiveUpdate {} (configTests ++ [ vmTests ])
