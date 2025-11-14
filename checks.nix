{ self, nixpkgs, git-hooks, ... }:

with nixpkgs.lib;

let
  hooks = {
    no-crlf-line-breaks = {
      enable = true;
      language = "pygrep";
      entry = "\r";
    };

    no-flake-lock = {
      enable = true;
      language = "fail";
      files = "flake.lock";
      entry = "flake.lock must not be committed";
    };

    no-amended-commits = {
      enable = true;
      stages = [ "pre-push" ];
      pass_filenames = false;
      entry = "sh " + builtins.toFile
        "check-committer-is-author" ''
          ! echo %H %{a,c}{n,e,d} |
          git log --format="$(cat)" |
          grep -Po '^.{40}(?!(.+)\1)'
        '';
    };
  };

  gitHooks =
    mapAttrs (platform: lib: {
      git-hooks = lib.run {
        src = self;
        configPath = ".git/hooks/config.json";
        inherit hooks;
      };
    }) git-hooks.lib;

  homeTests =
    mapAttrsToList (platform: system: {
      ${platform}.home-config =
        (system.extendModules {
          specialArgs.modules =
            attrValues self.homeModules;
          modules = [ ./asserts.nix ];
        }).activationPackage;
    }) self.homeConfigurations;

  droidTests =
    mapAttrsToList (platform: system: {
      ${platform}.droid-config =
        (system.config.build.extendModules {
          specialArgs.modules =
            attrValues self.nixOnDroidModules;
          modules = [ ./asserts.nix ];
        }).config.build.activationPackage;
    }) self.nixOnDroidConfigurations;

  nixosTests =
    mapAttrsToList (name: system: {
      ${system.pkgs.stdenv.system} = {
        "nixos-config-${name}" =
          (system.extendModules {
            modules = [ ./asserts.nix ];
          }).config.system.build.toplevel;
      };
    }) self.nixosConfigurations;
in

foldl' recursiveUpdate gitHooks
  (homeTests ++ droidTests ++ nixosTests)
