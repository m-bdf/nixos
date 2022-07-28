{
    outputs = { self, nixpkgs }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

    in {
        nixosConfigurations.mae = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit pkgs; };

            modules = builtins.map (module: ./config + "/${module}")
                (builtins.attrNames (builtins.readDir ./config));
        };

        packages.${system}.default = let
            nix-conf-file = (pkgs.nixos ./config/nix)
                .config.environment.etc."nix/nix.conf".source;

        in pkgs.writeShellScriptBin "build" "cat ${nix-conf-file}";
    };
}
