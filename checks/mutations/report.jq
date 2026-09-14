def killed: map(select(.[1] == "strong" and .[2] != null));

(map(select(.[1] == "strong")) | length) as $s
| (map(select(.[1] == "weak")) | length) as $w
| "",
  "\($s + $w)/\(length) mutants killed:",
  "  \($s) strong (some tests failed)",
  "  \($w) weak (evaluation aborted)",

  "",
  "Mutants by kind:", (
    map(.[0] |= split(" - ")[1])
    | group_by(.[0])
    | map({k: .[0][0],
           s: map(select(.[1] == "strong")) | length,
           w: map(select(.[1] == "weak")) | length})
    | sort_by([-(.s + .w), .k])[]
    | "\t\(.k) : \(.s + .w) (\(.s) strong / \(.w) weak)"
  ),

  "",
  "Mutants killed by each test:", (
    killed | [.[][2] / " " | .[]]
    | group_by(.)
    | map({t: first, n: length})
    | sort_by([-.n, .t])[]
    | "\t\(.t): \(.n)"
  ),

  "",
  "Tests with identical kill profiles:", (
    killed | [.[] as [$name, $v, $ts] | $ts / " " | .[] | [$name, .]]
    | group_by(.[1])
    | map({t: .[0][1], p: (map(.[0]) | sort | join(" "))})
    | group_by(.p)
    | map({n: length | select(. > 1),
           ts: (map(.t) | sort | join(" ")),
           m: (.[0].p | split(" ") | length)})
    | sort_by([-.n, .ts])[]
    | "\t\(.ts) (\(.n) tests, \(.m) mutants each)"
  ),

  "",
  "Mutants killed by the same tests:", (
    killed | group_by(.[2])
    | map({n: length | select(. > 1),
           m: (map(.[0]) | join(" ")),
           t: (.[0][2] | split(" ") | length)})
    | sort_by([-.n, .m])[]
    | "\t\(.m) (\(.n) mutants, \(.t) tests each)"
  )
