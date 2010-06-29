;; Stores (key, value) pair to memcached.
;; (key, value) pair are in data file as list of (key value)
(import (rnrs)
        (only (srfi :1) list-ref split-at!)
        (mosh control)
        (mosh concurrent)
        (mosh file)
        (memcached)
        (shorten)
        (mosh))

(let ([line* (map (^x (read (open-string-input-port x))) (file->list "/home/taro/Desktop/zipcode.sexp"))])
  (let loop ([line* line*]
             [i 0]
             [pid* '()])
    (let-values (([head tail] (if (< (length line*) 10000) (values line* '()) (split-at! line* 10000))))
      (cond
       [(null? head)
        (display "join start!\n")
        (for-each (^p (join! p)) pid*)
        (display "done\n")]
       [else
          (let1 pid (spawn (^x
                            (match x
                              [(my-index line*)
                                (let1 mc (memcached-connect (if (even? my-index) "10.12.0.2" "10.12.0.3") "11211")
                                  (format #t "<~d> started\n" i)
                                  (for-each
                                   (^l
                                    (memcached-set! mc (car l) 0 0 (cdr l)))
                                   line*)
                                  (format #t "<~d> end\n" i))]))
                           (list i line*)
                           '((rnrs) (mosh concurrent) (memcached) (mosh control) (shorten) (match)))
            (loop tail (+ i 1) (cons pid pid*)))]))))
