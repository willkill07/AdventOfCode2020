; parsing

(defun _split-sequence (val lst &key (start 0) end)
  (loop with val-length = (length val)
    for lst-start = start then (+ pos val-length)
    for lst-end = end
    for pos = (search val lst
                      :start2 lst-start
                      :end2 lst-end)
    collect (subseq lst lst-start pos)
    until (null pos)))

(defun split-lines (input)
  (_split-sequence '(#\Newline) input))

(defun _parse-interval (input)
  (destructuring-bind (low high) (_split-sequence "-" input)
    (cons (parse-integer low) (parse-integer high))))

(defun parse-intervals (input)
  (mapcar #'_parse-interval (_split-sequence " or " input)))

(defun _parse-field (input)
  (destructuring-bind (name rest) (_split-sequence ": " input)
    (list (cons :name name) (cons :intervals (parse-intervals rest)))))

(defun parse-fields (input)
  (mapcar #'_parse-field (_split-sequence '(#\Newline) input)))

(defun _parse-ticket (line)
  (mapcar #'parse-integer (_split-sequence "," line)))

(defun parse-tickets (input)
  (mapcar #'_parse-ticket (remove "" (rest (split-lines input)) :test #'equal)))

(defun parse-notes (input)
  (destructuring-bind (a b c) (_split-sequence #(#\Newline #\Newline) input)
    (list (cons :fields (parse-fields a))
          (cons :your-ticket (parse-tickets b))
          (cons :nearby-tickets (parse-tickets c)))))

; accessors

(defun field-name (fields)
  (cdr (assoc :name fields)))

(defun field-intervals (fields)
  (cdr (assoc :intervals fields)))

(defun field-valid-fields (field)
  (cdr (assoc :valid-fields field)))

(defun field-index (field)
  (cdr (assoc :index field)))

(defun field-indices (fields)
  (mapcar #'field-index fields))

(defun notes-fields (notes)
  (cdr (assoc :fields notes)))

(defun notes-your-ticket (notes)
  (cadr (assoc :your-ticket notes)))

(defun notes-nearby-tickets (notes)
  (cdr (assoc :nearby-tickets notes)))

(defun notes-rules (notes)
  (cdr (assoc :rules notes)))

(defun rules-bounds (rules)
  (cdr (assoc :bounds rules)))

; checks

(defun value-in-interval-p (interval value)
  (<= (car interval) value (cdr interval)))

(defun valid-for-field-p (field value)
  (some #'(lambda (interval) (value-in-interval-p interval value)) (field-intervals field)))

(defun _valid-for-some-field-p (fields value)
  (some #'(lambda (field) (valid-for-field-p field value)) fields))

(defun valid-ticket-p (fields ticket)
  (every #'(lambda (value) (_valid-for-some-field-p fields value)) ticket))

(defun all-valid-for-field-p (field values)
  (loop with intervals = (field-intervals field)
        for value in values
        always (loop for interval in intervals
                     for low fixnum = (car interval)
                     for high fixnum = (cdr interval)
                     thereis (<= low value high))))

; algorithms

(defun field-compute-valid-fields (field field-major-values)
  (acons :valid-fields
    (loop for index from 1
          for values in field-major-values
          if (all-valid-for-field-p field values)
            collect index)
    field))

(defun fields-add-valid-fields (fields field-major-values)
  (sort (loop for field in fields collect (field-compute-valid-fields field field-major-values))
        #'(lambda (a b) (< (length a) (length b)))
        :key #'field-valid-fields))

(defun solve-field-order-2 (index fields)
  (loop for field in fields
        for rest = (remove field fields :test #'eq)
        do (when (member index (field-valid-fields field))
             (if (null rest)
                 (return (list field))
                 (let ((ordered (solve-field-order-2 (1+ index) rest)))
                   (when ordered
                     (return (cons field ordered))))))))

(defun _remove-invalid-tickets (fields tickets)
  (remove-if-not #'(lambda (ticket) (valid-ticket-p fields ticket)) tickets))

(defun _rotate (list-of-lists)
  (apply #'mapcar #'list list-of-lists))

(defun _solve-field-order (notes)
  (let* ((fields             (notes-fields notes))
         (field-major-values (_rotate (_remove-invalid-tickets fields (notes-nearby-tickets notes))))
         (solved-fields      (solve-field-order-2 1 (fields-add-valid-fields fields field-major-values))))
    (loop for index from 0
          for field in solved-fields
          collect (acons :index index field))))

(defun departure-fields (notes)
  (remove-if-not #'(lambda (name) (eql 0 (search "departure " name)))
                 (_solve-field-order notes)
                 :key #'field-name))

(defun _bounds-to-sexp (bounds)
  (cons 'or (loop for bound in bounds collect `(<= ,(car bound) value ,(cdr bound)))))

(defun _rules-to-sexp (rules)
  (cons 'or (loop for rule in rules collect (_bounds-to-sexp (rules-bounds rule)))))

(defun rules-to-valid-value-p (rules)
  (eval `(lambda (value)
    (declare (type fixnum value)), (_rules-to-sexp rules))))

(defun file-get-contents (filename)
  (with-open-file (stream filename)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

; solvers

(defun part-one (notes)
  (loop with valid-value-p = (rules-to-valid-value-p (notes-rules notes))
    for ticket in (notes-nearby-tickets notes)
    sum (reduce #'+ (remove-if valid-value-p ticket))))

(defun part-two (notes)
  (loop with prod = 1
    with ticket = (notes-your-ticket notes)
    for index in (field-indices (departure-fields notes))
    do (setf prod (* prod (nth index ticket)))
    finally (return prod)))

; entrypoint

(setq input-string (file-get-contents "inputs/day16.txt"))
(setq notes (parse-notes input-string))

(print (part-one notes))
(print (part-two notes))
