let view = << t2 | t in $Base.recette$; t2 in $one:t$ >>
let () = ignore (Query.view ~log:stdout (PGOCaml.connect ()) view)
