(asdf:defsystem #:razor
  :description "Playing with Hutton's Razor in Coalton"
  :depends-on (#:coalton #:named-readtables)
  :serial t
  :components ((:file "package"))
  :in-order-to ((asdf:test-op (asdf:test-op #:razor/test))))

(asdf:defsystem #:razor/test
  :description "Unit testing"
  :depends-on (#:razor #:coalton/testing #:fiasco)
  :serial t
  :components ((:file "test"))
  :perform (asdf:test-op (o s)
                         (symbol-call '#:razor/test '#:run-tests)))
