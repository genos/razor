import gleeunit
import gleeunit/should
import qcheck
import razor_gleam.{Add, AddOp, Push, Val, compile, interpret, run}

pub fn main() -> Nil {
  gleeunit.main()
}

const expr = Add(Val(1), Val(2))

const nextpr = Add(Add(Val(0), Val(1)), Add(Val(2), Val(3)))

pub fn expr_test() {
  assert interpret(expr) == 3
  assert compile(expr) == [Push(1), Push(2), AddOp]
  assert run(compile(expr)) == Ok(3)
}

pub fn nextpr_test() {
  assert interpret(nextpr) == 6
  assert compile(nextpr)
    == [Push(0), Push(1), AddOp, Push(2), Push(3), AddOp, AddOp]
  assert run(compile(nextpr)) == Ok(6)
}

fn eg_inner(i: Int) {
  case i {
    i if i < 1 -> qcheck.map(qcheck.uniform_int(), Val)
    _ -> qcheck.map2(eg_inner(i - 1), eg_inner(i - 1), Add)
  }
}

fn expr_generator() {
  qcheck.sized_from(eg_inner, qcheck.bounded_int(0, 10))
}

pub fn interpret_compile_run_equivalent_test() {
  use e <- qcheck.given(expr_generator())
  should.equal(Ok(interpret(e)), run(compile(e)))
}
