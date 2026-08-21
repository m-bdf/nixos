{ writeShellApplication, path, lib, stdenv, writers, runCommand, nix, nixcov, gawk }:

let
  module = "asserts/default.nix";

  nixcovAnyNix = nixcov.overrideAttrs {
    postInstall = ''
      wrapProgram $out/bin/$pname \
        --set NIXCOV_INSTRUMENT_BIN $out/bin/nixcov-instrument
    '';
  };
in

writeShellApplication rec {
  name = "asserts-coverage";

  runtimeInputs = [ nixcovAnyNix gawk ];
  runtimeEnv.NIX_CONFIG = ''
    lazy-trees = false
    sandbox = false
  '';

  text = ''
    lcov=$(mktemp --tmpdir asserts.lcov-XXX)
    trap 'rm $lcov' EXIT

    nixcov --summary none --lcov "$lcov" \
      flake-build .#checks.${nixcov.system}.${name} --dry-run

    if [[ ! $(< "$lcov") =~ SF:${module} ]]; then
      echo 'FAIL: no coverage record for ${module},' \
        'did the test suite evaluate the module?' >&2
      exit 1
    fi

    uncovered=$(awk -F'[,:]' '
      $1 == "SF" && $2 == "${module}" { in_file = 1; next }
      in_file && $1 == "end_of_record" { in_file = 0; next }
      in_file && $1 == "DA" && $3 == 0 { print $2 }
    ' "$lcov" | sort -nu)

    if [[ -n "$uncovered" ]]; then
      # shellcheck disable=SC2086
      echo 'FAIL: ${module} has uncovered branches,' \
        'missing tests for lines:' $uncovered >&2
      exit 1
    fi

    echo "${module} fully covered by the test suite"
  '';
}
