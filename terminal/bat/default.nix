{ inputs, pkgs, ... }:

let
  bat = pkgs.bat.overrideAttrs (prev: {
    inherit (pkgs.deno) RUSTY_V8_ARCHIVE;

    cargoDeps =
      prev.cargoDeps.overrideAttrs (prev: {
        buildCommand = prev.buildCommand + ''
          ln -sf ${pkgs.rustPlatform.importCargoLock {
            lockFile = inputs.rustyscript + /Cargo.lock;
          }}/* $out
        '';
      });

    patchPhase = ''
      cargo add --path ${inputs.rustyscript} \
        --no-default-features --features fs_import

      sed 's|{HIGHLIGHTJS}|${inputs.highlightjs}|' \
        ${./highlight.rs} >> src/assets.rs

      sed -i '/get_first_line_syntax/ { s/fn /&_/
        s/\..*(/.get_syntax_for_file_contents(/ }' src/assets.rs

      sed -i 's/fn print_file_ranges/pub(crate) &/' src/controller.rs
    '';

    doCheck = false;
  });
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
