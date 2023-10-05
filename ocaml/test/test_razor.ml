open Razor

let first = Add (Val 1, Val 2)
let second = Add (Add (Val 0, Val 1), Add (Val 2, Val 3))
let interpret_ n e () = Alcotest.(check int) "interpret" n (interpret e)

let compile_ xs e () =
  let pp f c = Format.pp_print_string f (string_of_code c)
  and eq x y =
    match (x, y) with
    | Push a, Push b -> a == b
    | AddOp, AddOp -> true
    | _, _ -> false
  in
  let code = Alcotest.testable pp eq in
  Alcotest.(check (list code)) "compile" xs (compile e)

let compile_and_run_ n e () =
  Alcotest.(check int) "compile and run" n (run (compile e))

let gen_expr =
  let leaf i = Val i and node l r = Add (l, r) in
  QCheck2.Gen.(
    sized
    @@ fix (fun self n ->
           match n with
           | 0 -> map leaf nat
           | n ->
               let n' = n / 2 in
               frequency
                 [ (1, map leaf nat); (2, map2 node (self n') (self n')) ]))

let interpret_compile_equiv_ =
  QCheck_alcotest.to_alcotest
    QCheck2.(
      Test.make ~name:"interpretation ≡ compilation" ~count:10_000
        ~print:string_of_expr gen_expr (fun e -> interpret e = run (compile e)))

let () =
  let open Alcotest in
  run "Hutton's Razor"
    [
      ( "1st",
        [
          test_case "interpret" `Quick @@ interpret_ 3 first;
          test_case "compile" `Quick @@ compile_ [ Push 1; Push 2; AddOp ] first;
          test_case "compile and run" `Quick @@ compile_and_run_ 3 first;
        ] );
      ( "2nd",
        [
          test_case "interpret" `Quick @@ interpret_ 6 second;
          test_case "compile" `Quick
          @@ compile_
               [ Push 0; Push 1; AddOp; Push 2; Push 3; AddOp; AddOp ]
               second;
          test_case "compile and run" `Quick @@ compile_and_run_ 6 second;
        ] );
      ("QCheck2", [ interpret_compile_equiv_ ]);
    ]
