{ config, lib, ... }:

let
  rustixUseLibcOverlay = _: prev: {
    rustPlatform = prev.rustPlatform.overrideScope (_: prev: {
      buildRustPackage = args: with lib;
      let
        defaultPkg = prev.buildRustPackage args;
        pkgWithLibc = defaultPkg.overrideAttrs {
          passthru.dev = defaultPkg;
          NIX_RUSTFLAGS = "--cfg=rustix_use_libc";
        };

        manifest = importTOML (defaultPkg.src + /Cargo.toml);
        lock = importTOML (defaultPkg.src + /Cargo.lock);

        isCLI = elem "command-line-utilities"
          (manifest.workspace or manifest).package.categories or [];
        usesRustix = any (d: d.name == "rustix") lock.package;
      in
        if isCLI && usesRustix then pkgWithLibc else defaultPkg;
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
