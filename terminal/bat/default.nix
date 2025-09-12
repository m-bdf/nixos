{ inputs, pkgs, ... }:

let
  bat = pkgs.bat.overrideAttrs {
    inherit (pkgs.deno) RUSTY_V8_ARCHIVE;

    src = inputs.bat;
    cargoDeps =
      (pkgs.rustPlatform.importCargoLock {
        lockFile = inputs.bat + /Cargo.lock;
      }).overrideAttrs (prev: {
        buildCommand = prev.buildCommand + ''
          ln -sf ${pkgs.rustPlatform.importCargoLock {
            lockFile = inputs.rustyscript + /Cargo.lock;
          }}/* $out
        '';
      });

    patchPhase = ''
      cargo add --path ${inputs.rustyscript} --no-default-features

      sed 's|{HIGHLIGHTJS}|${inputs.highlightjs}|' \
        ${./highlight.rs} >> src/assets.rs

      sed -i '/get_first_line_syntax/ { s/fn /&_/
        s/\..*/.get_syntax_for_file_contents(input)?/ }' src/assets.rs

      sed -i 's/fn print_file(/pub(crate) &/' src/controller.rs

      sed -i "/append/ s/self.first_line/&.drain(..= \
        &.iter().position(|c| *c == b'\\\n').unwrap_or(&.len() - 1) \
      ).collect()/" src/input.rs
    '';

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

  home.sessionVariables.PAGER = "bat";
}
