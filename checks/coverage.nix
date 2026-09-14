{ path, runCommand, nix, nixcov }:

runCommand "futility-tests-coverage.lcov" {
  requiredSystemFeatures = [ "recursive-nix" ];
  nativeBuildInputs = [ nix nixcov ];
} ''
  cp -R ${./.} flake
  chmod +w flake

  echo "{
    outputs = { self, nixpkgs }: {
      checks.$system.futility-tests =
        assert (import ./tests {
          inherit (nixpkgs) lib;
        }) == null; self.outPath;
    };
  }" > flake/flake.nix

  export NIX_CACHE_HOME=$TMPDIR
  export NIX_CONFIG_HOME=$TMPDIR

  export NIX_CONFIG="
    experimental-features = nix-command flakes
    flake-registry = $NIX_CONFIG_HOME/registry.json
  "

  nix --offline registry add nixpkgs ${path}
  nix --offline flake lock ./flake

  nixcov check --summary none --lcov $out ./flake

  if ! grep -xq SF:futility.nix $out; then
    echo "FAIL: no coverage record for futility module" >&2
    exit 1
  fi

  uncovered=$(
    awk -F'[,:]' '
      $1 == "SF" && $2 == "futility.nix" { hit = 1 }
      $1 == "end_of_record"              { hit = 0 }
      hit && $1 == "DA" && $3 == 0       { print $2 }
    ' $out | sort -nu
  )

  if [[ -n $uncovered ]]; then
    echo "FAIL: uncovered lines of futility module: $uncovered" >&2
    exit 1
  fi
''
