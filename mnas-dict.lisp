;;;; mnas-dict.lisp

(in-package :mnas-dict)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; defclass

(defclass <language> ()
  ((key :accessor <language>-key :initform nil :initarg :key :documentation "name")))

(defmethod print-object ((language <language>) stream)
  (print-unreadable-object (language stream :type nil)
    (format stream "~A" (<language>-key language))))

(defclass <dictionary> ()
  ((uri  :accessor <dictionary>-uri  :initform "~/en-ru.dic" :initarg :uri
         :documentation "uri расположение для сериализации")
   (from :accessor <dictionary>-from :initform nil :initarg :from
         :documentation "Язык с которого осуществляется перевод.")
   (to   :accessor <dictionary>-to   :initform nil :initarg :to
         :documentation "Язык на который осуществляется перевод.")
   (ht   :accessor <dictionary>-ht   :initform (make-hash-table :test #'equal) :initarg :ht
         :documentation "Хешированная таблица")
   ))

(defmethod print-object ((dictionary <dictionary>) stream)
  (print-unreadable-object (dictionary stream :type t)
    (format stream "~A->~A ~S ~A" (<dictionary>-from dictionary)
            (<dictionary>-to dictionary)
            (<dictionary>-uri dictionary)
            (<dictionary>-ht dictionary))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod serialize ((dictionary <dictionary>))
  (with-open-file (stream (<dictionary>-uri dictionary)
                          :direction :output
                          :if-exists :supersede
                          :element-type 'unsigned-byte)
    (hu.dwim.serializer:serialize dictionary :output stream)))

(defmethod deserialize ((dictionary <dictionary>))
  (when (probe-file (<dictionary>-uri dictionary))
    (with-open-file (stream (<dictionary>-uri dictionary)
                            :direction :input
                            :element-type 'unsigned-byte)
      (hu.dwim.serializer:deserialize stream))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun read-triple-file (path)
  "@b(Описание:) функция @b(read-triple-file) возвращает список строк
хранящихся в файле с именем @b(path)."
  (let ((lines (uiop:read-file-lines path)))
    (loop :for i :in (cdr lines) :by #'cdddr
          :collect i)))


(defmethod add ((original string) (translation string) (dictionary <dictionary>))
  (setf (gethash original (<dictionary>-ht dictionary)) translation)
  dictionary)

(defmethod add ((original pathname) (translation pathname) (dictionary <dictionary>))
  "@b(Описание:) метод @b(add) добавляет данные в словарь из файлов в
тройном формате.

 @b(Пример использования:)
@begin[lang=lisp](code)
 (add #P\"D:/home/_namatv/PRG/msys64/home/namatv/devel/dictionary/ht.txt\"
      #P\"D:/home/_namatv/PRG/msys64/home/namatv/devel/dictionary/ht-ru.txt\"
      *dic*)
@end(code)
"
  (loop :for or :in (read-triple-file original)
        :for tr :in (read-triple-file translation)
        :do (add  or tr dictionary))
  dictionary)

(defmethod populate (original-translation-lst (dictionary <dictionary>) )
  (loop :for (original translation) :in original-translation-lst
        :do (add  original translation dictionary))
  dictionary)

(defmethod clear ((dictionary <dictionary>))
  (clrhash (<dictionary>-ht dictionary))
  dictionary)

(defmethod subtract ((minuend <dictionary>) (subtrahend <dictionary>))
  (loop :for k :being :the hash-keys :in (<dictionary>-ht subtrahend)
        :do (remhash k (<dictionary>-ht minuend)))
  minuend)

(defmethod write-key-single ((dictionary <dictionary>) &optional (stream t))
  (loop :for k :being :the hash-keys :in (<dictionary>-ht dictionary)
        :do (format stream "~A~%" k)))

(defmethod write-val-single ((dictionary <dictionary>) &optional (stream t))
  (loop :for k :being :the hash-keys :in (<dictionary>-ht dictionary) :using (hash-value v) 
        :do (format stream "~A~%" v)))

(defmethod write-key-triple ((dictionary <dictionary>) &optional (stream t))
  (loop :for k :being :the hash-keys :in (<dictionary>-ht dictionary)
        :for i :from 1
        :do (format stream "<<<<<< ~8D~%~A~%>>>>>>~%" i k)))

(defmethod write-val-triple ((dictionary <dictionary>) &optional (stream t))
  (loop :for k :being :the hash-keys :in (<dictionary>-ht dictionary) :using (hash-value v)
        :for i :from 1
        :do (format stream "<<<<<< ~8D~%~A~%>>>>>>~%" i v)))

(defmethod translate ((oriniginal string) (dictionary <dictionary>))
  (multiple-value-bind (translation exists)
      (gethash oriniginal (<dictionary>-ht dictionary))
    (if exists
        (values translation exists)
        (values oriniginal exists))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun add-by-tag (tag dictionary)
  (add
   (pathname
    (concatenate 'string "D:/home/_namatv/PRG/msys64/home/namatv/by-tag-wo-code/" tag ".txt"))
   (pathname
    (concatenate 'string "D:/home/_namatv/PRG/msys64/home/namatv/by-tag-wo-code_ru/" tag "_ru.txt"))
   dictionary))

(defun add-by-tags (tags dictionary)
  "@b(Описание:) функция @b(add-by-tags) добавляет записи словарь из
соответствующих файлов, связанных с определенными тегами."
  (map nil
       #'(lambda (tag)
           (add-by-tag tag dictionary))
       tags)
  dictionary)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod select-in-or (regexp (dictionary <dictionary>))
  "@b(Описание:) метод @b(find-in-origin) возвращает список, состоящий
из пар оригинал - перевод, оригиналы которых, соответствуют
регулярному выражению @b(regexp)."
  (loop :for k :being :the hash-keys
          :in (mnas-dict:<dictionary>-ht dictionary)
            :using (hash-value v)
        :when (ppcre:scan regexp k)
          :collect (list k v)))

(defmethod select-in-tr (regexp (dictionary <dictionary>))
  "@b(Описание:) метод @b(find-in-origin) возвращает список, состоящий
из пар оригинал - перевод, переводы которых, соответствуют регулярному
выражению @b(regexp)."
  (loop :for k :being :the hash-keys
          :in (mnas-dict:<dictionary>-ht dictionary)
            :using (hash-value v)
        :when (ppcre:scan regexp v)
          :collect (list k v)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#+nil
(defparameter *dic*
  (make-instance '<dictionary> :uri "~/dic-en-ru.dic" )
  "Словарь англо-русский.")

(defparameter *en-ru*
  (make-instance '<dictionary>
                 :from (make-instance '<language> :key :en)
                 :to   (make-instance '<language> :key :ru)
                 :uri "~/en-ru.dic" )
  "Словарь англо-русский.")

(setf *en-ru* (deserialize *en-ru*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
