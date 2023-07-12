;;;; mnas-dict.asd

(asdf:defsystem #:mnas-dict
  :description "Describe mnas-dict here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("hu.dwim.serializer")
  :components ((:file "package")
               (:file "mnas-dict")))
