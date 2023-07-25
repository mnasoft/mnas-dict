;;;; mnas-dict.asd

(asdf:defsystem "mnas-dict"
  :description "@b(Описание:) система @b(mnas-dict) определяет класс словаря
                и операции над ним."
  :author "Mykola Matvyeyev <mnasoft@gmail.com>"
  :license  "GNU GPL v3"
  :version "0.0.2"
  :serial t
  :depends-on ("hu.dwim.serializer")
  :components ((:file "package")
               (:file "mnas-dict")))
