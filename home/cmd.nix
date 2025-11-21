{ config, lib, ... }:

let
  rustixUseLibcOverlay = final: prev: {
    rustPlatform = prev.rustPlatform.overrideScope (_: prev: {
      buildRustPackage = args: with lib;
      let
        default = prev.buildRustPackage args;
        default' = prev.buildRustPackage.override (prev: {
          importCargoLock = prev.importCargoLock.override {
            runCommand = final.runCommandLocal;
          };
        }) args;

        withLibc = default'.overrideAttrs {
          passthru.dev = default;
          NIX_RUSTFLAGS = "--cfg=rustix_use_libc";
        };

        isCLI = elem "command-line-utilities"
          (importTOML (default.src + /Cargo.toml)).package.categories or [];
        usesRustix = any (d: d.name == "rustix")
          (importTOML (default.src + /Cargo.lock)).package;
      in
        if isCLI && usesRustix then withLibc else default;
    });
  };
in

{
  options = {
    _module.args = lib.mkOption {
      apply = args: args // {
        pkgs = args.pkgs.extend rustixUseLibcOverlay;
      };
    };

    home.path = config.lib.mkPathOption;
  };

  config = {
    lib.mkPathOption = lib.mkOption {
      apply = drv: drv.override (prev: {
        paths = prev.paths ++ lib.concatLists
          (lib.catAttrs "propagatedBuildInputs" prev.paths);
      });
    };

    programs = {
      fd.enable = true;
      ripgrep.enable = true;

      man.generateCaches = false;
    };
  };
}
