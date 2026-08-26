{ path, runCommand, nix, nixcov, jaq }:

let
  genMutants = ''
    .expressions | [.[1:], .[:-1]] | transpose[] as [$expr, $prev]

    | $expr.kind | scan("IF_ELSE|HAS_ATTR|UNARY_OP|BIN_OP") as $kind

    | $src | tobytes | .[$prev.byte_end :][1:3] as $op

    | select($kind != "BIN_OP" or $op == ("==", "!=", "&&", "||"))

    | .[$expr.byte_start : $expr.byte_end] |=
        if $kind == "IF_ELSE"
        then "if !\(.[3:])" | tobytes
        else "!(\(.))" | tobytes end

    | "\($expr.id)-\($kind):\(.)"
  '';
in

runCommand "asserts-mutations" {
  requiredSystemFeatures = [ "recursive-nix" ];
  nativeBuildInputs = [ nix nixcov jaq ];
} ''
  mkdir $out

  nix-instantiate --parse ${./default.nix} > module.nix

  nixcov-instrument instrument-source module.nix \
    --run-id covmap instrumented-module covmap.json

  jaq '${genMutants}' covmap.json \
    --rawfile src module.nix --raw-output0 |

  while IFS=: read -r -d "" name body; do
    printf '%s' "$body" > $out/$name.nix
  done

  for module in $out/*; do
    : $((total++))
    name=''${module##*/}
    name=''${name%.nix}

    if log=$(nix-instantiate \
      --eval ${./.}/tests.nix \
      --arg assertsModule $module \
      --arg lib 'import ${path}/lib' \
      --read-write-mode 2>&1
    ); then
      : $((survived++))
      echo "survived: $name"

    elif [[ $log == *'trace: FAIL'* ]]; then
      : $((strong++))
      echo "killed:   $name"
    else
      : $((weak++))
      echo "killed:   $name (weak)"
    fi
  done

  echo
  echo "$((strong + weak))/$((total)) killed:"
  echo "- $((strong)) strong (tests failed)"
  echo "- $((weak)) weak (evaluation aborted)"

  if ((survived)); then
    echo "FAIL: $survived survived (all tests passed)" >&2
    exit 1
  fi
''
