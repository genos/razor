(ns razor)

(def ^:const +expr+ '(1 2))
(def ^:const +nextpr+ '((0 1) (2 3)))

(defn interpret [e]
  (if (integer? e)
    e
    (+ (interpret (first e)) (interpret (second e)))))

(interpret +expr+)
(interpret +nextpr+)

(defn comp- [e]
  (if (integer? e)
    (list e)
    (concat (comp- (first e)) (comp- (second e)) (list :add))))

(comp- +expr+)
(comp- +nextpr+)

(defn run [ops]
  (first
    (reduce
      (fn [stack op]
        (if (integer? op)
          (cons op stack)
          (cons (+ (first stack) (second stack)) (nthrest stack 2))))
      nil ops)))

(run (comp- +expr+))
(run (comp- +nextpr+))
(-> +expr+ comp- run)
(-> +nextpr+ comp- run)
