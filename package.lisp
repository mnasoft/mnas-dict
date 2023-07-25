;;;; package.lisp

(defpackage :mnas-dict
  (:use #:cl)
  (:export <language>
           <language>-key
           )
  (:export <dictionary>            ; Класс словаря
           <dictionary>-uri        ; Расположение сериализации словаря
           <dictionary>-from       ; Язык оригинала
           <dictionary>-to         ; Язык перевода
           <dictionary>-ht         ; Хеш-таблица 
           )
  (:export serialize                    ; Сохранение в файл
           deserialize                  ; Восстановление из файла
           )
  (:export add                ; Добавление записей в словарь
           populate           ; Добавление записей в словарь из списка
           clear              ; Очистка словаря
           subtract           ; Разность словарей по оригиналу
           )
  (:export write-key-single ; Вывод оригиналов в файл в одиночном формате
           write-val-single ; Вывод переводов в файл в одиночном формате
           write-key-triple ; Вывод оригиналов в файл в тройном формате
           write-val-triple ; Вывод переводов в файл в тройном формате
           translate        ; Перевод 
           )
  (:export add-by-tag
           add-by-tags
           )
  (:export  select-in-or ; Выборка по регулярному выражению на оригиналах
            select-in-tr ; Выборка по регулярному выражению на переводах
            )
  (:export *en-ru*        ; Словарь его место в системе ansys-doc/clog
           ))

(in-package :mnas-dict)



