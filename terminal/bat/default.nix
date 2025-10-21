{ inputs, pkgs, ... }:

let
  rustyscript = pkgs.callPackage ./rustyscript.nix { inherit inputs; };

  bat = pkgs.bat.overrideAttrs (prev: {
    inherit (rustyscript) RUSTY_V8_ARCHIVE;

    cargoDeps = pkgs.symlinkJoin {
      name = "bat-cargo-deps";
      paths = [ prev.cargoDeps rustyscript.cargoDeps ];
    };

    configurePhase = ''
      cargo add --path ${rustyscript.src} --no-default-features
    '';

    patchPhase = ''
      sed -i 's/fn print_file(/pub(crate) &/' src/controller.rs

      sed -i "/append/ s/self.first_line/&.drain(..= \
        &.iter().position(|c| *c == b'\\\n').unwrap_or(&.len() - 1) \
      ).collect()/" src/input.rs

      sed -i '/get_first_line_syntax/ { s/fn /&_/
        s/\..*/.get_syntax_for_file_contents(input)?/ }' src/assets.rs

      sed 's|{HIGHLIGHTJS}|${inputs.highlightjs}|' \
        ${./highlight.rs} >> src/assets.rs
    '';

    doCheck = false;
  });
in

{
  programs.bat = {
    enable = true;
    package = bat;
    config = {
      pager = "builtin";
      style = "plain";
      theme = "GitHub Dark";
    };
    themes.github.src = inputs.github-textmate-theme;
  };

  home.sessionVariables.PAGER = "bat";
}
