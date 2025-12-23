import gleam/function
import gleam/int
import gleam/list
import gleam/result

pub type Expr {
  Val(Int)
  Add(Expr, Expr)
}

pub fn walk(e: Expr, f: fn(Int) -> t, g: fn(t, t) -> t) -> t {
  case e {
    Val(i) -> f(i)
    Add(x, y) -> g(walk(x, f, g), walk(y, f, g))
  }
}

pub fn interpret(e: Expr) -> Int {
  walk(e, function.identity, int.add)
}

pub type Code {
  Push(Int)
  AddOp
}

pub fn compile(e: Expr) -> List(Code) {
  walk(e, fn(x) { [Push(x)] }, fn(x, y) {
    list.append(x, list.append(y, [AddOp]))
  })
}

pub fn run(ops: List(Code)) -> Result(Int, Nil) {
  ops
  |> list.try_fold([], fn(stack, op) {
    case stack, op {
      _, Push(i) -> Ok([i, ..stack])
      [x, y, ..zs], AddOp -> Ok([x + y, ..zs])
      _, _ -> Error(Nil)
    }
  })
  |> result.try(list.first)
}
