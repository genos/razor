#[derive(Debug, PartialEq, Clone)]
pub enum Expr {
    Val(u64),
    Add(Box<ExprAdd>),
}

#[derive(Debug, PartialEq, Clone)]
pub struct ExprAdd {
    pub left: Expr,
    pub right: Expr,
}

impl Expr {
    fn walk<T>(&self, f: &impl Fn(u64) -> T, g: &impl Fn(T, T) -> T) -> T {
        match self {
            Expr::Val(i) => f(*i),
            Expr::Add(add) => {
                let ExprAdd {
                    ref left,
                    ref right,
                } = **add;
                g(left.walk(f, g), right.walk(f, g))
            }
        }
    }
}

#[must_use]
pub fn interpret(e: &Expr) -> u64 {
    e.walk(&|x| x, &u64::saturating_add)
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum Code {
    Push(u64),
    Add,
}

#[must_use]
pub fn compile(e: &Expr) -> Vec<Code> {
    e.walk(&|x| vec![Code::Push(x)], &|mut x, mut y| {
        x.append(&mut y);
        x.push(Code::Add);
        x
    })
}

#[must_use]
pub fn run(ops: impl Iterator<Item = Code>) -> Option<u64> {
    let mut stack = Vec::new();
    for op in ops {
        match op {
            Code::Push(i) => stack.push(i),
            Code::Add => {
                let x = stack.pop()?;
                let y = stack.pop()?;
                stack.push(x.saturating_add(y));
            }
        }
    }
    stack.pop()
}

#[cfg(test)]
mod tests {
    use super::*;
    use once_cell::sync::Lazy;
    use proptest::prelude::*;

    static EXPR: Lazy<Expr> = Lazy::new(|| {
        Expr::Add(Box::new(ExprAdd {
            left: Expr::Val(1),
            right: Expr::Val(2),
        }))
    });

    #[test]
    fn interpret_expr() {
        assert_eq!(3, interpret(&EXPR));
    }

    #[test]
    fn compile_expr() {
        assert_eq!(
            vec![Code::Push(1), Code::Push(2), Code::Add],
            compile(&EXPR)
        );
    }

    #[test]
    fn run_compile_expr() {
        assert_eq!(Some(3), run(compile(&EXPR).into_iter()));
    }

    static NEXTPR: Lazy<Expr> = Lazy::new(|| {
        Expr::Add(Box::new(ExprAdd {
            left: Expr::Add(Box::new(ExprAdd {
                left: Expr::Val(0),
                right: Expr::Val(1),
            })),
            right: Expr::Add(Box::new(ExprAdd {
                left: Expr::Val(2),
                right: Expr::Val(3),
            })),
        }))
    });

    #[test]
    fn interpret_nextpr() {
        assert_eq!(6, interpret(&NEXTPR));
    }

    #[test]
    fn compile_nextpr() {
        assert_eq!(
            vec![
                Code::Push(0),
                Code::Push(1),
                Code::Add,
                Code::Push(2),
                Code::Push(3),
                Code::Add,
                Code::Add,
            ],
            compile(&NEXTPR)
        );
    }

    #[test]
    fn run_compile_nextpr() {
        assert_eq!(Some(6), run(compile(&NEXTPR).into_iter()));
    }

    fn arb_expr() -> impl Strategy<Value = Expr> {
        any::<u64>()
            .prop_map(Expr::Val)
            .prop_recursive(8, 256, 10, |inner| {
                (inner.clone(), inner)
                    .prop_map(|(left, right)| Expr::Add(Box::new(ExprAdd { left, right })))
            })
    }

    proptest! {
        #[test]
        fn compile_equiv_interp(e in arb_expr()) {
            prop_assert_eq!(Some(interpret(&e)), run(compile(&e).into_iter()));
        }

    }
}
