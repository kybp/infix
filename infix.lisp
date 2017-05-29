(defstruct parser tokens output operators)

(defun consume-token (parser)
  (pop (parser-tokens parser)))

(defvar *synonyms* '((expt ^ **)))

(defvar *operators*
  '((nil . 0)
    (and . 1) (or . 1)
    (= . 2) (< . 2) (> . 2) (<= . 2) (>= . 2)
    (+ . 3) (- . 3)
    (* . 4) (/ . 4)
    (expt . 5)))

(defun precedence (operator)
  (cdr (assoc operator *operators*)))

(defun operatorp (symbol)
  (or (member symbol *operators* :key #'car)
      (member symbol *synonyms* :key #'cdr :test #'member)))

(defun canonical-operator-name (operator)
  (or (car (find operator *operators* :key #'car))
      (car (find operator *synonyms* :key #'cdr :test #'member))))

(defun call-operator (operator parser)
  (let* ((y (pop (parser-output parser)))
         (x (pop (parser-output parser)))
         (nils (count nil (list x y))))
    (if (> nils 0)
        (error "Operator ~s expected 2 arguments, but got ~s"
               operator (- 2 nils))
        (push (list operator x y) (parser-output parser)))))

(defun call-remaining-operators (parser)
  (loop for operator = (pop (parser-operators parser))
     while operator do (call-operator operator parser)
     finally (return (first (parser-output parser)))))

(defun push-operator (operator parser)
  (loop while (<= (precedence operator)
                  (precedence (first (parser-operators parser))))
     do (call-operator (pop (parser-operators parser)) parser))
  (push operator (parser-operators parser)))

(defun run-parser (parser)
  (loop while (parser-tokens parser)
     for token = (consume-token parser)
     if (operatorp token) do
       (push-operator (canonical-operator-name token) parser)
     else do
       (push token (parser-output parser))
     finally (return (call-remaining-operators parser))))

(defmacro infix (&rest tokens)
  (run-parser (make-parser :tokens tokens)))

(defun install-syntax ()
  (set-macro-character #\] (get-macro-character #\)))
  (set-macro-character
   #\[ #'(lambda (stream char)
           (declare (ignore char))
           (cons 'infix (read-delimited-list #\] stream)))))
