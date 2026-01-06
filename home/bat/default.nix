{ inputs, pkgs, ... }:

let
  craneLib = inputs.crane.mkLib pkgs;

  rustyscript = pkgs.callPackage ./rustyscript.nix
    { inherit inputs craneLib; };

  bat = craneLib.buildPackage {
    pname = "bat-highlight";
    inherit (pkgs.bat) version src meta;
    strictDeps = true;

    cargoArtifacts = rustyscript;
    cargoVendorDir =
      craneLib.vendorMultipleCargoDeps {
        cargoLockList = [
          (bat.src + /Cargo.lock)
          (rustyscript.src + /Cargo.lock)
        ];
      };

    postConfigure = ''
      cargo add --path ${rustyscript.src} --no-default-features
    '';

    inherit (rustyscript) RUSTY_V8_ARCHIVE;

    postPatch = ''
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
    themes."GitHub Dark" = {
      src = inputs.github-textmate-theme;
      file = "GitHub Dark.tmTheme";
    };
  };

  home.sessionVariables.PAGER = "bat";
}
