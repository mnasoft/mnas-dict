;;;; ./test.lisp

(in-package :mnas-dict)

(setf *dic* (deserialize *dic*))

(serialize *dic*)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Добавление или удаление пробелов в строку перевода как это есть в
;;;; оргинале.
(defun is-first-space (string)
  (char= (char string 0) #\Space))

(defun is-last-space (string)
  (char= (char string (1- (length string))) #\Space))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-by-tags
 '("h1" "h2" "h3" "h4" "h5" "h6" "h7" "h8" "ol" "ul" "td" "p")
 *en-ru*)

(serialize *en-ru*)

(progn
  (with-open-file (stream "~/single-key.txt"
                          :direction :output
                          :if-exists :supersede)
    (write-key-single *dic* stream))

  (with-open-file (stream "~/single-val.txt"
                          :direction :output
                          :if-exists :supersede)
    (write-val-single *dic* stream)))


(let ((i 0))
  (loop :for k :being :the hash-keys :in (<dictionary>-ht *dic*) :using (hash-value v)
        :do (when (string= v ">>>>>>")
              (remhash k  (<dictionary>-ht *dic*))
              (incf i)))
  i)

(defparameter *subtrahend*
  (make-instance '<dictionary> :uri "~/en-ru.dic"))
