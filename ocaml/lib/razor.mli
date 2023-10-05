type expr = Val of int | Add of expr * expr

val walk : (int -> 'a) -> ('a -> 'a -> 'a) -> expr -> 'a
val string_of_expr : expr -> string
val interpret : expr -> int

type code = Push of int | AddOp

val string_of_code : code -> string
val compile : expr -> code list
val run : code list -> int
