{ path, stdenv, nix, nixcov }:

stdenv.mkDerivation {
  name = "asserts-coverage";
  src = ./.;
  module = "default.nix";

  requiredSystemFeatures = [ "recursive-nix" ];
  nativeBuildInputs = [ nix nixcov ];

  patchPhase = ''
    echo "{
      outputs = { self, nixpkgs }: {
        checks.$system.$name =
          assert (import ./tests.nix {
            inherit (nixpkgs) lib;
          }) == null; self.outPath;
      };
    }" > flake.nix
  '';

  configurePhase = ''
    export NIX_CACHE_HOME=$TMPDIR
    export NIX_CONFIG_HOME=$TMPDIR
    export NIX_CONFIG="
      experimental-features = nix-command flakes
      flake-registry = $NIX_CONFIG_HOME/registry.json
    "
    nix --offline registry add nixpkgs ${path}
    nix --offline flake lock
  '';

  buildPhase = ''
    nixcov check --summary none --lcov $out

    if ! grep -xq SF:$module $out; then
      echo FAIL: no coverage record for $module, \
        did the test suite evaluate the module? >&2
      exit 1
    fi
  '';

  installPhase = ''
    uncovered=$(awk -F'[,:]' '
      $1 == "SF" && $2 == "'$module'" { in_mod = 1 }
      in_mod && $1 == "end_of_record" { in_mod = 0 }
      in_mod && $1 == "DA" && $3 == 0 { print $2 }
    ' $out | sort -nu)

    if [[ $uncovered ]]; then
      echo FAIL: $module has uncovered branches, \
        missing tests for lines: $uncovered >&2
      exit 1
    fi
  '';
}
