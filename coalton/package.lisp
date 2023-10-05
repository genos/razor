(defpackage #:razor
  (:use #:coalton #:coalton-prelude)
  (:export #:Val #:Add #:interpret #:Push #:AddOp #:comp #:run #:comp-and-run))
(cl:in-package #:razor)

(named-readtables:in-readtable coalton:coalton)

(coalton-toplevel

  (define-type Expr
    (Val Integer)
    (Add Expr Expr))

  (declare interpret (Expr -> Integer))
  (define (interpret e)
    (match e
      ((Val i) i)
      ((Add x y) (+ (interpret x) (interpret y)))))

  (define-type Op
    (Push Integer)
    (AddOp))

  (define-instance (Eq Op)
    (define (== a b)
      (match (Tuple a b)
        ((Tuple (Push x) (Push y)) (== x y))
        ((Tuple (AddOp) (AddOp)) True)
        (_ False))))

  (declare comp-and-run (Expr -> (Optional Integer)))
  (define comp-and-run
    (compose run comp))

  (declare comp (Expr -> (List Op)))
  (define (comp e)
    (match e
      ((Val i) (singleton (Push i)))
      ((Add x y) (append (comp x) (append (comp y) (singleton AddOp))))))

  (declare run ((List Op) -> (Optional Integer)))
  (define (run code)
    (head
      (fold
        (fn (stack op)
          (match (Tuple stack op)
            ((Tuple _ (Push i)) (Cons i stack))
            ((Tuple (Cons x (Cons y s)) (AddOp)) (Cons (+ x y) s))
            ((Tuple s o) (error "Unexpected case: stack = ~a, op = ~a" s o))))
        Nil
        code))))
