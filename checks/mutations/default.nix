{ path, callPackage, runCommand, nix, jaq }:

runCommand "futility-tests-mutations.tsv" {
  requiredSystemFeatures = [ "recursive-nix" ];
  nativeBuildInputs = [ nix jaq ];
  mutants = callPackage ./mutants.nix {};
} ''
  assays() {
    nix-instantiate --eval ${../tests} --arg futility $1 \
      --arg lib 'import ${path}/lib' --read-write-mode |&
    sed -nE 's/trace: FAIL "test(.+)":|^ *(error: )/\1\2/p'
  }

  if ! assays ${../futility.nix}; then
    echo 'FAIL: the suite fails on the unmutated module' >&2
    exit 1
  fi

  for module in $mutants/*-*.nix; do
    IFS=- read id kind <<< $(basename $module .nix)
    printf '%4u - %-8s\t' $id $kind | tee -a $out

    if log=$(assays $module); then
      echo 'survived' | tee -a $out
      diff -u $mutants/parsed.nix $module

    elif errors=($(grep -v '^error: ' <<< $log)); then
      printf 'strong\t%s\n' "''${errors[*]}" >> $out
      printf 'killed (%u tests failed)\n' ''${#errors[@]}

    else
      printf 'weak\t%s\n' "$log" >> $out
      printf 'killed (%s)\n' "$log"
    fi
  done | sort -n

  if survived=$(grep -Pc '\tsurvived\t' $out); then
    echo "FAIL: $survived survived (all tests passed)" >&2
    exit 1
  fi

  jaq -f ${./report.jq} -sr $out
''
