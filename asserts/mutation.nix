{ path, writeShellScriptBin, runCommand, nixcov, jaq }:

let
  mkMutatedModules = ''
    def isws(n): n == 9 or n == 10 or n == 13 or n == 32;

    def opat($b; $i):
      first(["&&", "||", "==", "!=", "<=", ">="][] | select($b[$i:$i+2] == .))
      // first(["<", ">"][] | select($b[$i:$i+1] == .));

    def inany($p; $rs): any($rs[]; $p >= .[0] and $p < .[1]);

    def flip:
      { "&&": "||"
      , "||": "&&"
      , "==": "!="
      , "!=": "=="
      , "<=": ">"
      , "<": ">="
      , ">=": "<"
      , ">": "<="
      };

    ($srcModule | tobytes) as $b

    | [ .expressions[]
        | select((.file | endswith("default.nix"))
            and (.kind | test("^NODE_(BIN_OP|HAS_ATTR|IF_ELSE|UNARY_OP)$")))
      ] as $s

    | [ $s[] | select(.kind == "NODE_BIN_OP") | [.byte_start, .byte_end] ] as $rs

    | (
        [ $s[]
          | if .kind == "NODE_HAS_ATTR"
            then
              ["hasattr-\(.id)", .byte_start, .byte_end - .byte_start, "N", ""]
            elif .kind == "NODE_UNARY_OP" and $b[.byte_start] == 33
            then
              ["negate-\(.id)", .byte_start, 1, "R", ""]
            elif .kind == "NODE_IF_ELSE"
            then
              ($b[.byte_start:.byte_end] | index("then" | tobytes)) as $t
              | if $t == null
                then empty
                else
                  ($b[.byte_start:.byte_start + $t]) as $raw
                  | ([range($raw | length) | select(isws($raw[.]) | not)]) as $ns
                  | first($ns[] | select(. >= 2)) as $lo  # skip the `if` keyword
                  | $ns[-1] as $hi
                  | ["ifneg-\(.id)", .byte_start + $lo, $hi - $lo + 1, "N", ""]
                end
            else empty
            end
        ]
        +
        [ range(0; $b | length) as $i
          | opat($b; $i) as $o
          | select(inany($i; $rs))
          | ["flip-\($i)", $i, ($o | length), "R", flip[$o]]
        ]
      ) as $ms

    | $ms[]
      | . as $m
      | $b[:$m[1]]
        + (if $m[3] == "N"
           then ("(!(" | tobytes) + $b[$m[1]:$m[1] + $m[2]] + ("))" | tobytes)
           else ($m[4] | tobytes)
           end)
        + $b[$m[1] + $m[2]:] as $out
      | $m[0] + ":" | tobytes + $out
  '';

  mutations =
    runCommand "mutated-asserts-modules" {
      nativeBuildInputs = [ nixcov jaq ];
    } ''
      mkdir $out

      nixcov-instrument instrument-source \
        --run-id covmap ${./default.nix} . covmap.json

      jaq '${mkMutatedModules}' covmap.json \
        --rawfile srcModule ${./default.nix} --to raw0 |

      while IFS=: read -r -d "" name contents; do
        printf '%s' "$contents" > $out/$name.nix
      done
    '';
in

writeShellScriptBin "asserts-mutation" ''
  for module in ${mutations}/*; do
    ((total++))
    name=''${module##*/}
    name=''${name%.nix}

    if log=$(nix-instantiate \
      --eval ${./.}/tests.nix \
      --argstr assertsModule $module \
      --arg lib 'import ${path}/lib' 2>&1
    ); then
      ((survived++))
      echo "survived: $name"

    elif [[ $log == *'trace: FAIL'* ]]; then
      ((strong++))
      echo "killed:   $name"
    else
      ((weak++))
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
