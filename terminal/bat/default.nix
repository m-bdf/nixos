{ inputs, lib, pkgs, ... }:

let
  addCargoDeps = pkg: deps:
    pkg.overrideAttrs (final: prev: {
      srcCargoDeps =
        pkgs.rustPlatform.importCargoLock {
          lockFile = final.src + /Cargo.lock;
        };

      cargoDeps =
        final.srcCargoDeps.overrideAttrs (prev: {
          buildCommand = prev.buildCommand +
            lib.concatMapStrings (dep: ''
              cp -rsu ${dep.cargoDeps}/* $out
            '') (lib.toList deps);
        });

      configurePhase =
        lib.concatMapStrings (dep: ''
          cargo add --path ${dep.src} -${
            lib.optionalString dep.cargoBuildNoDefaultFeatures "-no"
          }-default-features --features=${
            lib.concatStringsSep "," dep.cargoBuildFeatures
          }
        '') (lib.toList deps);
    });

  rustyscript = pkgs.rustPlatform.buildRustPackage {
    name = "rustyscript";
    src = inputs.rustyscript;
    cargoLock.lockFile = inputs.rustyscript + /Cargo.lock;

    buildNoDefaultFeatures = true;
    buildFeatures = [ "url_import" ];
  };

  bat = (addCargoDeps pkgs.bat rustyscript).overrideAttrs {
    src = inputs.bat;
    patchPhase = ''
      cat ${./highlight.rs} >> src/assets.rs
      sed -i '/get_first_line_syntax/ { s/fn /&_/
        s/\..*(/.get_syntax_for_file_contents(/ }' src/assets.rs
      sed -i 's/fn print_file_ranges/pub(crate) &/' src/controller.rs
    '';

    inherit (pkgs.deno) RUSTY_V8_ARCHIVE;
    doCheck = false;
  };
in

{
  programs.bat = {
    enable = true;
    package = bat;
    config = {
      style = "plain";
      theme = "GitHub Dark";
    };
    themes.github.src = inputs.github-textmate-theme;
  };
}
