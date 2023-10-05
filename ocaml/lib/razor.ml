type expr = Val of int | Add of expr * expr

let rec walk f g = function
  | Val i -> f i
  | Add (l, r) -> g (walk f g l) (walk f g r)

let string_of_expr =
  let f i = Format.sprintf "Val %d" i
  and g l r = Format.sprintf "Add (%s, %s)" l r in
  walk f g

let interpret = walk Fun.id Int.add

type code = Push of int | AddOp

let string_of_code = function
  | Push i -> Format.sprintf "Push %d" i
  | AddOp -> "AddOp"

let compile =
  let f i = [ Push i ] and g l r = l @ r @ [ AddOp ] in
  walk f g

let run ops =
  List.hd
    (List.fold_left
       (fun stack op ->
         match (stack, op) with
         | _, Push i -> i :: stack
         | x :: y :: zs, AddOp -> (x + y) :: zs
         | _, _ ->
             let ss = String.concat ", " (List.map string_of_int stack)
             and os = String.concat ", " (List.map string_of_code ops) in
             raise
               (Failure
                  (Format.sprintf "Unexpected case; stack = %s, ops = %s" ss os)))
       [] ops)
