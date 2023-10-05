(defpackage #:razor/test
  (:use #:razor #:coalton #:coalton-prelude #:coalton-testing)
  (:export #:run-tests))
(cl:in-package #:razor/test)

(named-readtables:in-readtable coalton:coalton)

(fiasco:define-test-package #:razor/fiasco-test-package)
(coalton-fiasco-init #:razor/fiasco-test-package)

(coalton-toplevel
  (define +expr+ (Add (Val 1) (Val 2)))
  (define +nextpr+ (Add
                     (Add (Val 0) (Val 1))
                     (Add (Val 2) (Val 3)))))

(cl:defun run-tests ()
  (fiasco:run-package-tests
    :packages '(#:razor/fiasco-test-package)
    :interactive cl:t))

(define-test interpret-expr ()
  (is (== 3 (interpret +expr+))))

(define-test comp-expr ()
  (is (== (Cons (Push 1) (Cons (Push 2) (singleton AddOp))) (comp +expr+))))

(define-test comp-and-run-expr ()
  (is (== (Some 3) (comp-and-run +expr+))))

(define-test interpret-nextpr ()
  (is (== 6 (interpret +nextpr+))))

(define-test comp-nextpr ()
  (is (==
        (Cons (Push 0)
              (Cons (Push 1)
                    (Cons AddOp
                          (Cons (Push 2)
                                (Cons (Push 3)
                                      (Cons AddOp (singleton AddOp)))))))
        (comp +nextpr+))))

(define-test comp-and-run-nextpr ()
  (is (== (Some 6) (comp-and-run +nextpr+))))
