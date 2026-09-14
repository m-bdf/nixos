{ runCommand, nix, nixcov, jaq }:

let
  genMutants = ''
    ($src | tobytes) as $s

    | [.expressions[] | select(.kind == "NODE_BIN_OP")
       | {byte_start, byte_end}] as $spans

    | [.expressions[1:], .expressions[:-1]] | transpose[] as [$e, $p]

    | $e.kind | scan("IF_ELSE|HAS_ATTR|UNARY_OP|BIN_OP|SELECT") as $kind

    | $s[$p.byte_end:][1:3] as $op

    | select($kind != "BIN_OP" or $op == ("==", "!=", "&&", "||"))

    | [$e.byte_start, $e.byte_end] as [$a, $b]

    | if $kind == "BIN_OP" then
        ["\($e.id)-BIN_OP",
         ($s | .[$a:$b] |= ("!(\(.))" | tobytes))],

        ({"&&": "||", "||": "&&"}[$op] as $flop
         | select($flop)
         | ["\($e.id)-FLIP",
            ($s | .[$p.byte_end+1:$p.byte_end+3] |= ($flop | tobytes))])

      elif $kind == "SELECT" then
        select(any($spans[];
                   .byte_start <= $e.byte_start
                   and $e.byte_end <= .byte_end))
        | $s[$a:$b] | rindex("." | tobytes) as $dot
        | select($dot > 0 and (. | index(" or " | tobytes) | not))
        | ["\($e.id)-SELECT",
           ($s | .[$a:$b] |= (.[:$dot] | tobytes))]

      else
        ["\($e.id)-\($kind)",
         ($s | .[$a:$b] |=
           (if $kind == "IF_ELSE" then "if !\(.[3:])" else "!(\(.))" end
            | tobytes))]
      end

    | join(":")
  '';
in

runCommand "futility-tests-mutants" {
  requiredSystemFeatures = [ "recursive-nix" ];
  nativeBuildInputs = [ nix nixcov jaq ];
} ''
  mkdir $out
  nix-instantiate --parse ${../futility.nix} > $out/parsed.nix

  nixcov-instrument instrument-source $out/parsed.nix \
    --run-id covmap instrumented $out/covmap.json

  jaq '${genMutants}' $out/covmap.json \
    --rawfile src $out/parsed.nix --raw-output0 |
  while IFS=: read -r -d "" name body; do
    printf '%s' "$body" > $out/$name.nix
  done

  if ! ls $out/*-*.nix >/dev/null; then
    echo 'FAIL: no mutants were generated' >&2
    exit 1
  fi
''
