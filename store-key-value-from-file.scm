;; Stores (key, value) pair to memcached.
;; (key, value) pair are in data file as list of (key value)
(import (rnrs)
        (only (srfi :1) list-ref split-at! take drop)
        (mosh control)
        (mosh concurrent)
        (mosh file)
        (memcached)
        (shorten)
        (mosh))

(define *data-file* "/home/taro/Desktop/zipcode.sexp")
(define *number-of-processes* 3)
(define *unit-size* 500)
(define *hosts* '#("10.12.4.40" "10.12.4.41" "10.12.4.42" "10.12.4.43" "10.12.4.44"
                   "10.12.4.45" "10.12.4.46" "10.12.4.47" "10.12.4.48" "10.12.4.49"))
(define host-index 0)
(define (start-worker line*)
  (let1 host (vector-ref *hosts* (mod host-index (vector-length *hosts*)))
    (set! host-index (+ host-index 1))
    (spawn (^(x)
             (match x
               [(l* host)
                (let1 mc (memcached-connect host "11211")
                  (for-each
                   (^l
                    (memcached-set! mc (car l) 0 "10" (cdr l)))
                   l*)
                  (memcached-close mc))
                ]))
           (list line* host)
           '((rnrs) (mosh concurrent) (memcached) (mosh control) (shorten) (match) (mosh)))))

(let ([lines (map (^x (read (open-string-input-port x))) (file->list *data-file*))])
  (let loop ([line* lines]
             [pid* '()]
             [i 0])
    (cond
     [(= (length pid*) *number-of-processes*)
      (join! (car (drop pid* (- (length pid*) 1))))
      (format #t "~d/~d\n" (* (+ i 1) *unit-size*) (length lines))
      (loop line* (take pid* (- (length pid*) 1)) (+ i 1))]
     [else
      (let-values (([head tail] (if (< (length line*) *unit-size*) (values line* '()) (split-at! line* *unit-size*))))
        (let1 pid (start-worker head)
          (loop tail (cons pid pid*) i)))])))


;;     (let-values (([head tail] (if (< (length line*) *unit-size*) (values line* '()) (split-at! line* *unit-size*))))
;;       (cond
;;        [(null? head)
;;         (display "join start!\n")
;;         (for-each (^p (join! p)) pid*)
;;         (display "done\n")]
;;        [else
;;           (let1 pid (spawn (^x
;;                             (match x
;;                               [(my-index line*)
;;                                 (let1 mc (memcached-connect (vector-ref '#("10.12.4.40" "10.12.4.41") #;'#("10.12.0.2" "10.12.0.3" "10.12.0.16" "10.12.0.20") (mod my-index 4)) "11211")
;;                                   (format #t "<~d> started\n" my-index)
;;                                   (for-each
;;                                    (^l
;;                                     (memcached-set! mc (car l) 0 "10" (cdr l)))
;;                                    line*)
;;                                   (format #t "<~d> end\n" my-index))]))
;;                            (list i line*)
;;                            '((rnrs) (mosh concurrent) (memcached) (mosh control) (shorten) (match) (mosh)))
;;             (loop tail (+ i 1) (cons pid pid*)))]))))
