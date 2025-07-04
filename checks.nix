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

  configTests =
    mapAttrsToList (name: system: {
      ${system.pkgs.stdenv.system}.${name} =
        (system.extendModules {
          modules = [ ./asserts.nix ];
        }).config.system.build.toplevel;
    }) self.nixosConfigurations;
in

foldl' recursiveUpdate gitHooks configTests
