(defun expression-p (e) (or (integerp e) (consp e)))
(deftype expression () '(satisfies expression-p))

(defconstant +expr+ '(1 2))

(format t "~A~%" +expr+)
(format t "~A~%" (typep +expr+ 'expression))

(declaim (ftype (function (expression) integer) interpret))
(defun interpret (e)
  (declare (optimize (debug 0) (safety 0) (speed 3)))
  (if (integerp e)
      e
      (+ (interpret (first e)) (interpret (second e)))))

#+nil(disassemble 'interpret)

(format t "~A~%" (interpret +expr+))

(defun code-p (op) (or (integerp op) (eq op 'add)))
(deftype code () '(satisfies code-p))

(declaim (ftype (function (expression) (cons code)) comp))
(defun comp (e)
  (declare (optimize (debug 0) (safety 0) (speed 3)))
  (if (integerp e)
      (list e)
      (append (comp (first e)) (comp (second e)) '(add))))

#+nil(disassemble 'comp)

(format t "~A~%" (comp +expr+))

(declaim (ftype (function ((cons code)) integer) run))
(defun run (ops)
  (declare (optimize (debug 0) (safety 0) (speed 3)))
  (let ((stack nil))
    (dolist (op ops (first stack))
      (push
        (if (integerp op) op (+ (pop stack) (pop stack)))
        stack))))

(format t "~A~%" (run (comp +expr+)))

#+nil(disassemble 'run)

(defun comp-and-run (e)
  (declare (optimize (debug 0) (safety 0) (speed 3)))
  (run (comp e)))

#+nil(disassemble 'comp-and-run)

(format t "~A~%" (comp-and-run +expr+))

(defconstant +nextpr+ '((0 1) (2 3)))

(format t "~{~A~%~}" (list
                       +nextpr+
                       (interpret +nextpr+)
                       (comp +nextpr+)
                       (comp-and-run +nextpr+)))
