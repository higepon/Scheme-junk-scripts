;; For debugging memory usage on multiple processes
(import (rnrs)
        (only (srfi :1) list-ref split-at! take drop)
        (mosh control)
        (mosh concurrent)
        (mosh file)
        (memcached)
        (shorten)
        (mosh))

(define (start-worker line*)
  (spawn (^(line*)
           #;(receive
               ['stop '()])
           (display 'done)
           (process-exit 0))
         '(line*)
         '((rnrs) (mosh concurrent) (memcached) (mosh control) (shorten) (match) (mosh))
         ))

(define (fibo n)
  (if (<= n 1)
      n
      (+ (fibo (- n 1)) (fibo (- n 2)))))

;; (define *data-file* "/home/taro/Desktop/zipcode.sexp")
;; (define *unit-size* 500)
;; (let ([lines (map (^x (read (open-string-input-port x))) (file->list *data-file*))])
;; (let loop ([i 0]
;; ;           [pid* '()]
;;            [line* lines])
;;     (cond
;;      [(= i 5)
;; ;      (for-each (^p (! p 'stop)) pid*)
;; ;      (for-each join! pid*)
;;       ]
;;      [else
;;       (let-values (([head tail] (if (< (length line*) *unit-size*) (values line* '()) (split-at! line* *unit-size*))))
;;       (display "spawn")
;;       (newline)
;;       (let1 pid (start-worker head)
;; ;        (sleep 5000)
;;         (loop (+ i 1) #;(cons pid pid*) tail)))])))

(join! (start-worker 3))

(fibo 34)
(display "hige")
(sleep 10000000)
